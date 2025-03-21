import 'dart:convert';

import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// Embed image.
///
/// Children shall all be text content.
class ImageTag extends EmbedTag {
  /// Constructor.
  const ImageTag({required super.start, required super.end, required super.attribute, super.children});

  /// Build empty one.
  static const ImageTag empty = ImageTag(start: -1, end: -1, attribute: '');

  static final _imageSizeRe = RegExp(r'^(?<width>\d+),(?<height>\d+)$');

  @override
  String get name => 'img';

  @override
  AttributeValidator get attributeValidator =>
      (input) => input == null || input.isEmpty || _imageSizeRe.hasMatch(input);

  @override
  String get quillEmbedName => 'bbcodeImage';

  @override
  String get quillEmbedValue {
    final m = _imageSizeRe.firstMatch(attribute ?? '');
    final rawLink = children.firstOrNull?.data;
    final String? link;
    if (rawLink == null) {
      link = null;
    } else if (!rawLink.startsWith('https://')) {
      link = 'https://www.tsdm39.com/$rawLink';
    } else {
      link = rawLink;
    }

    return jsonEncode({'link': link, 'width': m?.namedGroup('width') ?? '', 'height': m?.namedGroup('height') ?? ''});
  }

  /// Children shall be text content.
  @override
  ChildrenValidator get childrenValidator => (children) => children.every((e) => e.isPlainText);

  @override
  ImageTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      ImageTag(start: head.start, end: tail?.end ?? head.end, attribute: head.attribute, children: children);
}
