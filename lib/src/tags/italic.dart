import 'package:dart_bbcode_parser/src/tags/common_tag.dart';

/// Tag name.
class ItalicTag extends NoAttrTag {
  /// Constructor.
  const ItalicTag();

  @override
  String get name => 'i';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'italic';

  @override
  dynamic get quillAttrValue => true;
}
