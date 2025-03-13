import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class FontSizeTag extends CommonTag {
  /// Constructor.
  const FontSizeTag({required String attribute, super.children}) : super(attribute: attribute);

  @override
  String get name => 'size';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'size';

  @override
  dynamic get quillAttrValue => true;

  @override
  FontSizeTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      FontSizeTag(attribute: head.attribute!, children: children);
}
