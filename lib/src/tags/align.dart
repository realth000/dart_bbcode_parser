import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// Align tag.
///
/// Align the current paragraph.
/// By default allows:
///
/// * `[align=left]` align to left.
/// * `[align=center]` align to center.
/// * `[align=right]` align to right.
class AlignTag extends CommonTag {
  /// Constructor.
  const AlignTag({required String attribute, super.children}) : super(attribute: attribute);

  @override
  String get name => 'align';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'align';

  @override
  String get quillAttrValue => super.attribute!;

  @override
  AttributeValidator get attributeValidator => (attr) => attr != null && ['left', 'center', 'right'].contains(attr);

  @override
  AlignTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      AlignTag(attribute: head.attribute!, children: children);
}
