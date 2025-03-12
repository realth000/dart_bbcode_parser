import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class SuperscriptTag extends NoAttrTag {
  /// Constructor.
  const SuperscriptTag({super.children});

  @override
  String get name => 'sup';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'script';

  @override
  String get quillAttrValue => 'super';

  @override
  SuperscriptTag fromToken(TagHead head, TagTail tail, List<BBCodeTag> children) => SuperscriptTag(children: children);
}

