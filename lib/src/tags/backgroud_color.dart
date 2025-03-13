import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:dart_bbcode_web_colors/dart_bbcode_web_colors.dart';

/// Tag name.
class BackgroundColorTag extends CommonTag {
  /// Constructor.
  const BackgroundColorTag({required String attribute, super.children}) : super(attribute: attribute);

  @override
  String get name => 'backcolor';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'background';

  @override
  String get quillAttrValue => super.attribute!;

  @override
  AttributeValidator get attributeValidator => (input) => input.toColor() != null;

  @override
  BackgroundColorTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      BackgroundColorTag(attribute: head.attribute!, children: children);
}
