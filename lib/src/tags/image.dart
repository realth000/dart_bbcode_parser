import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Tag name.
class ImageTag extends EmbedTag {
  /// Constructor.
  const ImageTag({required String attribute, super.children}) : super(attribute: attribute);

  @override
  String get name => 'img';

  @override
  String get quillEmbedName => 'bbcodeImage';

  // TODO: Validate and parse image url from children.
  @override
  String get quillEmbedValue => throw UnimplementedError();

  @override
  ImageTag fromToken(TagHead head, TagTail tail, List<BBCodeTag> children) =>
      ImageTag(attribute: head.attribute!, children: children);
}
