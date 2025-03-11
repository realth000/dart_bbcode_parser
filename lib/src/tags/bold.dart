import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class BoldTag extends NoAttrTag {
  /// Constructor.
  const BoldTag({super.children});

  @override
  String get name => 'b';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'bold';

  @override
  bool get quillAttrValue => true;

  @override
  BoldTag fromToken(TagHead head, TagTail tail, List<BBCodeTag> children) => BoldTag(children: children);
}
