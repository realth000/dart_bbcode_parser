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
  const AlignTag({required super.start, required super.end, required super.attribute, super.children});

  /// Build empty one.
  static const AlignTag empty = AlignTag(start: -1, end: -1, attribute: '');

  @override
  String get name => 'align';

  @override
  ApplyTarget get target => ApplyTarget.paragraph;

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'align';

  @override
  String get quillAttrValue => super.attribute!;

  @override
  AttributeValidator get attributeValidator => (attr) => attr != null && ['left', 'center', 'right'].contains(attr);

  @override
  AlignTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      AlignTag(start: head!.start, end: tail?.end ?? head.end, attribute: head.attribute, children: children);
}
