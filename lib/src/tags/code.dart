import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Raw code block. `[code]`.
class CodeTag extends CommonTag {
  /// Constructor.
  const CodeTag({required super.start, required super.end, super.children});

  /// Build empty one.
  static const empty = CodeTag(start: -1, end: -1);

  @override
  bool get hasQuillAttr => true;

  @override
  ApplyTarget get target => ApplyTarget.paragraph;

  @override
  String get name => 'code';

  @override
  String get quillAttrName => 'code-block';

  @override
  bool get quillAttrValue => true;

  @override
  BBCodeTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) {
    if (children.isEmpty) {
      return CodeTag(start: head.start, end: tail?.end ?? head.end, children: []);
    }

    var buffer = StringBuffer();

    for (final child in children) {
      buffer = child.toBBCode(buffer);
    }

    return CodeTag(
      start: head.start,
      end: tail?.end ?? head.end,
      children: [TextContent(children.first.start, children.last.end, buffer.toString())],
    );
  }
}
