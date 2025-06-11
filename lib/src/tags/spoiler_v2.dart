import 'dart:convert';

import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Spoiler v2 tag header in bbcode editor.
class SpoilerV2HeaderTag extends EmbedTag {
  /// Constructor.
  const SpoilerV2HeaderTag({required super.start, required super.end, required super.attribute});

  /// Build empty one.
  static const empty = SpoilerV2HeaderTag(start: -1, end: -1, attribute: null);

  static const _defaultTitle = '展开/收起';

  @override
  String get name => 'spoiler';

  @override
  String get quillEmbedName => 'bbcodeSpoilerV2Header';

  @override
  bool get selfClosed => true;

  @override
  String get quillEmbedValue => jsonEncode({'title': attribute ?? _defaultTitle});

  @override
  SpoilerV2HeaderTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      SpoilerV2HeaderTag(start: head!.start, end: tail?.end ?? head.end, attribute: head.attribute);
}

/// Spoiler v2 tag tail in bbcode editor.
class SpoilerV2TailTag extends EmbedTag {
  /// Constructor.
  const SpoilerV2TailTag({required super.start, required super.end});

  /// Build empty one.
  static const empty = SpoilerV2TailTag(start: -1, end: -1);

  @override
  String get name => 'spoiler';

  @override
  bool get selfClosed => true;

  @override
  bool get selfClosedAtTail => true;

  @override
  String get quillEmbedName => 'bbcodeSpoilerV2Tail';

  @override
  String get quillEmbedValue => '';

  @override
  SpoilerV2TailTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      SpoilerV2TailTag(start: tail!.start, end: tail.end);
}
