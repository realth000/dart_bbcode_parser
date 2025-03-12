import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class StrikethroughTag extends NoAttrTag {
  /// Constructor.
  const StrikethroughTag({super.children});

  @override
  String get name => 's';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'strike';

  @override
  bool get quillAttrValue => true;

  @override
  StrikethroughTag fromToken(TagHead head, TagTail tail, List<BBCodeTag> children) => StrikethroughTag(children: children);
}
