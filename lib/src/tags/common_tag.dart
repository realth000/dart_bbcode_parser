import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Common common and base tags.
///
/// Defines open character, close character, self closing and children validator.
abstract class CommonTag extends BBCodeTag {
  // False positive.
  // ignore: prefer_const_constructor_declarations
  /// Constructor.
  CommonTag({
    super.start,
    super.end,
    super.attribute,
    super.children,
    super.attributeValidator,
    super.childrenValidator,
    super.parentValidator,
  });

  @override
  bool get isPlainText => false;

  @override
  String get data => throw UnsupportedError('shall not calling data on non-plain-text tag');

  @override
  String get open => '[';

  @override
  String get close => ']';

  @override
  bool get selfClosed => false;

  @override
  bool get selfClosedAtTail => false;

  @override
  bool get hasQuillEmbed => false;

  @override
  String get quillEmbedName => throw UnsupportedError('common tag has no quill embed');

  @override
  String get quillEmbedValue => throw UnsupportedError('common tag has no quill embed');

  @override
  ChildrenValidator? get childrenValidator => null;

  @override
  AttrContext toQuilDelta(AttrContext attrContext) {
    var ac = attrContext..save(this);
    // Ensure paragraphs are prefixed with new line.
    if (target == ApplyTarget.paragraph && quillAttrName != null && ac.endWithNewLine == false) {
      ac.addOperations([Operation.insert('\n')]);
    }

    for (final child in children) {
      ac = child.toQuilDelta(ac);
    }

    if (children.isEmpty) {
      ac.addOperations([Operation.insert('', ac.attrMap)]);
    }

    ac.restore(this);

    // Ensure paragraphs are suffixed with new line.
    if (target == ApplyTarget.paragraph && quillAttrName != null && ac.endWithNewLine == false) {
      ac.addOperations([
        Operation.insert('\n', {quillAttrName!: quillAttrValue}),
      ]);
    }
    return ac;
  }
}

/// Tag with no attribute.
abstract class NoAttrTag extends CommonTag {
  // False positive.
  // ignore: prefer_const_constructor_declarations
  /// Constructor.
  NoAttrTag({
    required super.start,
    required super.end,
    super.children,
    super.attributeValidator,
    super.childrenValidator,
  });

  @override
  String? get attribute => null;

  @override
  AttributeValidator get attributeValidator => nullAttributeValidator;
}

/// Tags using embed in quill delta.
abstract class EmbedTag extends BBCodeTag {
  // False positive.
  // ignore: prefer_const_constructor_declarations
  /// Constructor.
  EmbedTag({
    required super.start,
    required super.end,
    super.attribute,
    super.children,
    super.attributeValidator,
    super.childrenValidator,
    super.parentValidator,
  });

  @override
  bool get isPlainText => false;

  @override
  String get data => throw UnsupportedError('shall not calling data on non-plain-text tag');

  @override
  String get open => '[';

  @override
  String get close => ']';

  @override
  bool get selfClosed => false;

  @override
  bool get selfClosedAtTail => false;

  @override
  bool get hasQuillAttr => false;

  @override
  String get quillAttrName => throw UnsupportedError('embed has no attr name');

  @override
  String get quillAttrValue => throw UnsupportedError('embed has no attr value');

  @override
  bool get hasQuillEmbed => true;

  @override
  ChildrenValidator? get childrenValidator => null;

  @override
  AttrContext toQuilDelta(AttrContext attrContext) {
    attrContext.operation.add(Operation.insert({quillEmbedName: quillEmbedValue}, attrContext.attrMap));
    final paragraphAttrs = attrContext.paragraphAttrMap;
    // Ensure embed tags inside children have attr.
    // But does it break composed content in paragraph node?
    if (paragraphAttrs.isNotEmpty) {
      attrContext.operation.add(Operation.insert('\n', paragraphAttrs));
    }
    return attrContext;
  }
}
