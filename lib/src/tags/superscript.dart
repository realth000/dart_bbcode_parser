import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class SuperscriptTag extends NoAttrTag {
  /// Constructor.
  const SuperscriptTag({required super.start, required super.end, super.children});

  /// Constructor.
  static const SuperscriptTag empty = SuperscriptTag(start: -1, end: -1);

  @override
  String get name => 'sup';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'script';

  @override
  String get quillAttrValue => 'super';

  @override
  SuperscriptTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      SuperscriptTag(start: head.start, end: tail?.end ?? head.end, children: children);
}

