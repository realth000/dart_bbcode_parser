import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Quote block. `[quote]`
class QuoteTag extends CommonTag {
  /// Constructor.
  const QuoteTag({required super.start, required super.end, super.children});

  /// Build empty one.
  static const empty = QuoteTag(start: -1, end: -1);

  @override
  AttributeValidator? get attributeValidator => nullAttributeValidator;

  @override
  bool get hasQuillAttr => true;

  @override
  ApplyTarget get target => ApplyTarget.paragraph;

  @override
  String get name => 'quote';

  @override
  String get quillAttrName => 'blockquote';

  @override
  bool get quillAttrValue => true;

  @override
  BBCodeTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      QuoteTag(start: head!.start, end: tail?.end ?? head.end, children: children);
}
