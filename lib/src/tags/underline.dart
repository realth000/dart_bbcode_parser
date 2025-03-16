import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class UnderlineTag extends NoAttrTag {
  /// Constructor.
  const UnderlineTag({required super.start, required super.end, super.children});

  /// Build empty one.
  static const empty = UnderlineTag(start: -1, end: -1);

  @override
  String get name => 'u';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'underline';

  @override
  bool get quillAttrValue => true;

  @override
  UnderlineTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      UnderlineTag(start: head.start, end: tail?.end ?? head.end, children: children);
}
