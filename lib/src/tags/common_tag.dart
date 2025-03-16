import 'dart:convert';

import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Common common and base tags.
///
/// Defines open character, close character, self closing and children validator.
abstract class CommonTag extends BBCodeTag {
  /// Constructor.
  const CommonTag(
      {super.start, super.end, super.attribute, super.children, super.attributeValidator, super.childrenValidator});

  @override
  bool get isPlainText => false;

  @override
  String get data => throw Exception('shall not calling data on non-plain-text tag');

  @override
  String get open => '[';

  @override
  String get close => ']';

  @override
  bool get selfClosed => false;

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
    if (target == ApplyTarget.paragraph && quillAttrName != null) {
      ac.addOperations([Operation.insert('\n', {})
      ]);
    }
    for (final child in children) {
      ac = child.toQuilDelta(ac);
    }
    ac.restore(this);

    // Paragraph attributes in quill delta are applied on a separate paragraph (text "\n") after current paragraph.
    if (target == ApplyTarget.paragraph && quillAttrName != null) {
      ac.addOperations([Operation.insert('\n', {
        quillAttrName!: quillAttrValue,
      })
      ]);
    }
    return ac;
  }

  @override
  String toString() => '''
$runtimeType {
    open="$open",
    close="$close",
    selfClosed=$selfClosed,
    attr=${attribute != null ? "$attribute" : null}
    children = ${children.map((e) => e.toString()).join('\n')}
}''';
}

/// Tag with no attribute.
abstract class NoAttrTag extends CommonTag {
  /// Constructor.
  const NoAttrTag(
      {required super.start, required super.end, super.children, super.attributeValidator, super.childrenValidator});


  @override
  String? get attribute => null;

  @override
  AttributeValidator? get attributeValidator => null;
}

/// Tags using embed in quill delta.
abstract class EmbedTag extends BBCodeTag {
  /// Constructor.
  const EmbedTag(
      {required super.start, required super.end, super.attribute, super.children, super.attributeValidator, super.childrenValidator});

  @override
  bool get isPlainText => false;

  @override
  String get data => throw Exception('shall not calling data on non-plain-text tag');

  @override
  String get open => '[';

  @override
  String get close => ']';

  @override
  bool get selfClosed => false;

  @override
  bool get hasQuillAttr => false;

  @override
  String? get quillAttrName => null;

  @override
  String get quillAttrValue => throw UnsupportedError('embed has no attr value');

  @override
  bool get hasQuillEmbed => true;

  @override
  ChildrenValidator? get childrenValidator => null;

  @override
  AttrContext toQuilDelta(AttrContext attrContext) {
    attrContext.operation.add(Operation.insert({quillEmbedName: quillEmbedValue}, attrContext.attrMap));
    return attrContext;
  }

  @override
  String toString() => '''
$runtimeType {
    open="$open",
    close="$close",
    selfClosed=$selfClosed,
    attr=${attribute != null ? "$attribute" : null}
    children = ${children?.map((e) => e.toString()).join('\n')}
}''';
}
