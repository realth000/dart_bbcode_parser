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
  const CommonTag({super.attribute, super.children, super.attributeValidator, super.childrenValidator});

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
    var ac = AttrContext();
    for (final child in (children ?? const <BBCodeTag>[])) {
      attrContext.save(this);
      ac = child.toQuilDelta(attrContext)..restore(this);
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
    children = ${children?.map((e) => e.toString()).join('\n')}
}''';
}

/// Tag with no attribute.
abstract class NoAttrTag extends CommonTag {
  /// Constructor.
  const NoAttrTag({super.children, super.attributeValidator, super.childrenValidator});

  @override
  String? get attribute => null;

  @override
  AttributeValidator? get attributeValidator => null;
}

/// Tags using embed in quill delta.
abstract class EmbedTag extends BBCodeTag {
  /// Constructor.
  const EmbedTag({super.attribute, super.children, super.attributeValidator, super.childrenValidator});

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
  Map<String, dynamic> get quillAttrValue => {};

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
