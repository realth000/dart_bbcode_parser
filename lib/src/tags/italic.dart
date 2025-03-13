import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class ItalicTag extends NoAttrTag {
  /// Constructor.
  const ItalicTag({super.children});

  @override
  String get name => 'i';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'italic';

  @override
  dynamic get quillAttrValue => true;

  @override
  ItalicTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) => ItalicTag(children: children);
}
