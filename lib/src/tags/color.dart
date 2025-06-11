import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:dart_bbcode_web_colors/dart_bbcode_web_colors.dart';

/// Tag name.
class ColorTag extends CommonTag {
  /// Constructor.
  const ColorTag({required super.start, required super.end, required String attribute, super.children})
    : super(attribute: attribute);

  /// Build empty one.
  static const empty = ColorTag(start: -1, end: -1, attribute: '');

  @override
  String get name => 'color';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'color';

  @override
  String get quillAttrValue => super.attribute!;

  @override
  AttributeValidator get attributeValidator => (input) => input.toColor() != null;

  @override
  ColorTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      ColorTag(start: head!.start, end: tail?.end ?? head.end, attribute: head.attribute!, children: children);
}
