import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class StrikethroughTag extends NoAttrTag {
  /// Constructor.
  const StrikethroughTag({required super.start, required super.end, super.children});

  /// Build empty one.
  static const empty = StrikethroughTag(start: -1, end: -1);

  @override
  AttributeValidator? get attributeValidator => nullAttributeValidator;

  @override
  String get name => 's';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'strike';

  @override
  bool get quillAttrValue => true;

  @override
  StrikethroughTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      StrikethroughTag(start: head!.start, end: tail?.end ?? head.end, children: children);
}
