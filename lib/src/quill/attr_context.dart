import 'package:dart_bbcode_parser/src/quill/convertible.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// The attributes context go through conversion.
class AttrContext {
  /// Constructor.
  AttrContext()
      : attrs = [],
        paragraphAttrs = [],
        operation = [];

  /// All attributes on text.
  List<QuillAttribute> attrs;

  /// All attributes on paragraph.
  ///
  /// Till now this field is not used because paragraph attributes are manually attached to a new paragraph when
  /// finished parsing current tag. It's what quill delta expected, though we do not have "paragraph" concept in bbcode.
  List<QuillAttribute> paragraphAttrs;

  /// All operations.
  List<Operation> operation;

  /// Get attrs in map format.
  Map<String, dynamic> get attrMap => Map.fromEntries(attrs.map((e) => MapEntry(e.name, e.value)));

  /// Get paragraph attributes in map format.
  Map<String, dynamic> get paragraphAttrMap => Map.fromEntries(paragraphAttrs.map((e) => MapEntry(e.name, e.value)));

  /// Check if context ended with '\n'.
  bool? get endWithNewLine {
    if (operation.isEmpty) {
      return null;
    }

    final lastOp = operation.lastOrNull?.data;
    if (lastOp is! String) {
      return null;
    }
    return lastOp.endsWith('\n');
  }

  /// Add attributes into the context.
  //
  // The attribute value is dynamic type according to quill delta definition.
  // ignore: avoid_dynamic
  void _remember(String attrName, dynamic attrValue) {
      attrs.add(QuillAttribute(attrName, attrValue));
  }

  void _rememberForParagraph(String attrName, dynamic attrValue) {
    paragraphAttrs.add(QuillAttribute(attrName, attrValue));
  }

  /// Forget last attribute from context.
  void _forget(String tagName) {
    // Shall not throw empty element exception.
    if (attrs.isEmpty) {
      throw Exception('did you forget to save tags?');
    }

    if (attrs.last.name != tagName) {
      throw Exception('forgetting incorrect tag: intend to forget "$tagName", but exactly have "${attrs.last.name}"');
    }
    attrs.removeLast();
  }

  void _forgetForParagraph(String tagName) {
    // Shall not throw empty element exception.
    if (paragraphAttrs.isEmpty) {
      throw Exception('did you forget to save paragraph tags?');
    }

    if (paragraphAttrs.last.name != tagName) {
      throw Exception(
          'forgetting incorrect paragraph tag: intend to forget "$tagName", but exactly have "${attrs.last.name}"');
    }
    paragraphAttrs.removeLast();
  }

  /// Save the attribute in [tag] to context.
  void save(BBCodeTag tag) {
    if (!tag.hasQuillAttr) {
      return;
    }

    if (tag.target == ApplyTarget.paragraph) {
      _rememberForParagraph(tag.quillAttrName!, tag.quillAttrValue);
      return;
    }

    _remember(tag.quillAttrName!, tag.quillAttrValue);
  }

  /// Remove the attribute in [tag] from context.
  void restore(BBCodeTag tag) {
    if (!tag.hasQuillAttr) {
      return;
    }

    if (tag.target == ApplyTarget.paragraph) {
      _forgetForParagraph(tag.quillAttrName!);
      return;
    }

    _forget(tag.quillAttrName!);
  }

  /// Add operations.
  void addOperations(Iterable<Operation> ops) {
    operation.addAll(ops);
  }

  /// Add a single operation.
  void tryAddOperation(Operation? op) {
    if (op == null) {
      return;
    }
    operation.add(op);
  }
}
