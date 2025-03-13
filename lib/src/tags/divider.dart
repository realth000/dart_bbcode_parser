import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Horizontal divider.
class DividerTag extends EmbedTag {
  /// Constructor.
  const DividerTag({super.children});

  @override
  String get name => 'hr';

  @override
  bool get selfClosed => true;

  @override
  bool get hasQuillAttr => false;

  @override
  String get quillEmbedName => 'bbcodeDivider';

  @override
  String get quillEmbedValue => 'hr';

  @override
  DividerTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) => DividerTag(children: children);

}
