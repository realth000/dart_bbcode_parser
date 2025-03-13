import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class UnderlineTag extends NoAttrTag {
  /// Constructor.
  const UnderlineTag({super.children});

  @override
  String get name => 'u';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'underline';

  @override
  bool get quillAttrValue => true;

  @override
  UnderlineTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) => UnderlineTag(children: children);
}
