import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

extension _UpdateOperationListAttr on Operation {
  Operation withListAttr(ListType listType) {
    final attrs = attributes?.withListAttr(listType);

    return Operation(key, length, data, attrs);
  }
}

extension _UpdateListAttr on Map<String, dynamic>? {
  Map<String, dynamic> withListAttr(ListType listType) {
    final m = this;
    if (m == null) {
      return {'list': listType.quillAttrValue};
    }

    m['list'] = listType.quillAttrValue;
    return m;
  }
}

class _TransformContext {
  _TransformContext(this.listType);

  /// Current list type.
  ListType listType;

  /// We are in list or not.
  bool inItem = false;
}

/// Types of list.
enum ListType {
  /// Type not decided.
  ///
  /// This type means the list item is outside of list scope.
  undecided(''),

  /// Ordered list.
  ///
  /// `[list=1]`
  ordered('ordered'),

  /// Bullet list.
  ///
  /// `[list]`
  bullet('bullet');

  const ListType(this.quillAttrValue);

  /// Parse list type from string.
  factory ListType.rawBBCode(String? rawType) => switch (rawType) {
    final String v when v == '1' => ListType.ordered,
    _ => ListType.bullet,
  };

  /// Parse list type from string.
  factory ListType.raw(String? rawType) => switch (rawType) {
    final String v when v == 'ordered' => ListType.ordered,
    final String v when v == 'bullet' => ListType.bullet,
    _ => ListType.undecided,
  };

  /// The const quill attribute value held by each list type.
  final String quillAttrValue;
}

/// Ordered list or bullet list.
///
/// ```console
/// Ordered list: [list=1]
/// Bullet list: [list]
/// ```
///
/// Each item in list shall be started with `[*]` at the start of each new line.
///
/// ## Restrictions
///
/// Note that, server side rendering allows multi-line content in each list item:
///
/// ```console
/// [list]
/// [*]a
/// b
/// c
/// [/list]
/// ```
///
/// In the above example, "a\nb\nc" will be rendered in the same list item and all lines have correct ident.
///
/// But multi-line content in list item is not supported by upstream Quill Editor. Though we could manually add indents
/// to the trailing lines, it only seems work in bullet list, still breaks numbering of each line if in ordered list.
///
/// So multi-line content in list item is discouraged. We could render it, but not able to write it.
///
/// Consider this as a coner case, it's fine to run this way.
class ListTag extends CommonTag {
  /// Constructor.
  const ListTag({required super.start, required super.end, required super.attribute, required super.children});

  /// Build empty one.
  static const empty = ListTag(start: 0, end: 0, attribute: null, children: null);

  String _normalizeString(String s) {
    final endedWithLF = s.endsWith('\n');
    final ss = s.replaceAll('\n', '');
    return endedWithLF ? '$ss\n' : ss;
  }

  /// Currently:
  ///
  /// * Embed tags are not supported.
  /// * Multiline text are not supported.
  /// * Tag and text outside of `[*]` are ignored.
  ///
  /// When building children:
  ///
  /// * Embed tags will fallback to plain text.
  /// * Multiline text strip lines.
  /// * Ignore tag and text if out of list item scope.
  List<BBCodeTag> _transformChildren(List<BBCodeTag> children, _TransformContext context) {
    final ret = <BBCodeTag?>[];
    for (final child in children) {
      ret.add(_transformChild(child, context));
    }

    return ret.whereType<BBCodeTag>().toList();
  }

  BBCodeTag? _transformChild(BBCodeTag child, _TransformContext context) {
    if (child.hasQuillEmbed) {
      // Fallback embed children tags.
      final start = child.start;
      final end = child.end;
      final buffer = StringBuffer();
      child.fallbackToText(buffer);
      // Don't forget to strip lines as multiline text are not supported.
      return TextContent(start: start, end: end, data: _normalizeString(buffer.toString()));
    } else if (child.isPlainText) {
      if (!context.inItem) {
        // Skip item outside of any item or null text data.
        return null;
      }

      // Flatten multiline text to single line.
      final start = child.start;
      final end = child.end;
      // Don't forget to strip lines as multiline text are not supported.
      return TextContent(start: start, end: end, data: _normalizeString(child.data!));
    } else if (child.name == ListItemTag.empty.name) {
      // Record item scope.
      context.inItem = true;
      // Revise the item.
      return ListItemTag(start: child.start, end: child.end, listType: context.listType);
    }

    final transformedChildren = <BBCodeTag?>[];
    for (final child in child.children) {
      transformedChildren.add(_transformChild(child, context));
    }

    // Replace the original children with transformed ones.
    // While the `children` field is `final`, and BBCodeTag is an abstract class, we can not instantiate it directly.
    // Use the `fromToken` as bridge.
    return child.fromToken(
      TagHead(name: child.name, start: child.start, end: child.start, attribute: child.attribute),
      TagTail(name: child.name, start: child.end, end: child.end),
      transformedChildren.whereType<BBCodeTag>().toList(),
    );
  }

  @override
  bool get hasQuillAttr => false;

  @override
  String get name => 'list';

  @override
  String? get quillAttrName => null;

  @override
  String? get quillAttrValue => null;

  @override
  ListTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) => ListTag(
    start: head!.start,
    end: tail?.end ?? head.end,
    attribute: head.attribute,
    children: _transformChildren(children, _TransformContext(ListType.rawBBCode(head.attribute))),
  );
}

/// List item in list.
///
/// Each tag is an instance in the generated list, `[*]` in BBCode or `<li>` in Html.
///
/// By default, the list type is not decided as item may be not inside known list.
class ListItemTag extends NoAttrTag {
  /// Constructor.
  const ListItemTag({required super.start, required super.end, required this.listType});

  /// Move list paragraph attribute to next one.
  static List<Operation> normalizeListItemQuill(List<Operation> operations) {
    final ret = <Operation>[];
    var deferredAttr = ListType.undecided;
    for (final op in operations) {
      if (op.key != 'insert') {
        // Unreachable.
        // All operations generated by parsing process are insert operations.
        ret.add(op);
        continue;
      }

      if (op.value is! String || op.value != '\n') {
        ret.add(op);
        continue;
      }

      // Here we have an operation like this:
      //
      // ``` json
      // {
      //   "insert": "\n",
      //   "attributes": {
      //     "list": "bullet"
      //   }
      // }
      // ```
      //
      // If the operation has attribute 'list', then this 'list' attribute should be moved to the following same.
      // line wrap paragraph operation.

      final currListType = ListType.raw(op.attributes?['list'] as String?);

      final Operation newOp;

      if (currListType == ListType.undecided && deferredAttr != ListType.undecided) {
        // Current operation has not 'list' attribute
        // but we have the list attribute moved from previous operation.
        // Apply to make the 'move' complete.
        newOp = op.withListAttr(deferredAttr);
        deferredAttr = ListType.undecided;
      } else if (currListType != ListType.undecided && deferredAttr != ListType.undecided) {
        // Last paragraph has list attribute, and current paragraph, too.
        // Keep moving.
        newOp = op.withListAttr(deferredAttr);
        deferredAttr = currListType;
      } else if (currListType == ListType.undecided && deferredAttr == ListType.undecided) {
        newOp = op;
      } else if (currListType != ListType.undecided && deferredAttr == ListType.undecided) {
        // Current paragraph has list but previous do not have it.
        // Record the list type and remove it from current paragraph, start 'moving'.
        final m =
            op.attributes ?? {}
              ..remove('list');
        newOp = Operation(op.key, op.length, op.data, m);
        deferredAttr = currListType;
      } else {
        // Unreachable, condition is exhausted.
        newOp = op;
      }

      ret.add(newOp);
    }

    return ret;
  }

  /// Build empty one.
  static const empty = ListItemTag(start: 0, end: 0, listType: ListType.bullet);

  /// List type.
  final ListType listType;

  @override
  bool get hasQuillAttr => switch (listType) {
    ListType.undecided => false,
    ListType.ordered => true,
    ListType.bullet => true,
  };

  @override
  String get name => '*';

  @override
  String? get quillAttrName => switch (listType) {
    ListType.undecided => null,
    _ => 'list',
  };

  @override
  String? get quillAttrValue => switch (listType) {
    ListType.undecided => null,
    final v => v.quillAttrValue,
  };

  @override
  bool get selfClosed => true;

  @override
  ApplyTarget get target => ApplyTarget.paragraph;

  @override
  ListItemTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      ListItemTag(start: head!.start, end: tail?.end ?? head.end, listType: ListType.undecided);
}
