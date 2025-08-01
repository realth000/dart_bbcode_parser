import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Horizontal divider.
class DividerTag extends EmbedTag {
  /// Constructor.
  const DividerTag({required super.start, required super.end, super.children});

  /// Build empty one.
  static const DividerTag empty = DividerTag(start: -1, end: -1);

  @override
  String get name => 'hr';

  @override
  AttributeValidator? get attributeValidator => nullAttributeValidator;

  @override
  bool get selfClosed => true;

  @override
  String get quillEmbedName => 'bbcodeDivider';

  @override
  String get quillEmbedValue => 'hr';

  @override
  DividerTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      DividerTag(start: head!.start, end: tail?.end ?? head.start, children: children);
}
