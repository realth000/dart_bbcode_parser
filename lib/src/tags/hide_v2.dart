import 'dart:convert';

import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// Hide v2 tag header in bbcode editor.
class HideV2HeaderTag extends EmbedTag {
  /// Constructor.
  const HideV2HeaderTag({required super.start, required super.end, required super.attribute});

  /// Build empty one.
  static const empty = HideV2HeaderTag(start: -1, end: -1, attribute: null);

  @override
  String get name => 'hide';

  @override
  String get quillEmbedName => 'bbcodeHideV2Header';

  @override
  AttributeValidator? get attributeValidator => (attr) => attr == null || (int.tryParse(attr) ?? -1) >= 0;

  @override
  bool get selfClosed => true;

  @override
  String get quillEmbedValue => jsonEncode({'points': int.tryParse(attribute ?? '') ?? 0});

  @override
  HideV2HeaderTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      HideV2HeaderTag(start: head!.start, end: tail?.end ?? head.end, attribute: head.attribute);
}

/// Hide v2 tag tail in bbcode editor.
class HideV2TailTag extends EmbedTag {
  /// Constructor.
  const HideV2TailTag({required super.start, required super.end});

  /// Build empty one.
  static const empty = HideV2TailTag(start: -1, end: -1);

  @override
  String get name => 'hide';

  @override
  bool get selfClosed => true;

  @override
  bool get selfClosedAtTail => true;

  @override
  String get quillEmbedName => 'bbcodeHideV2Tail';

  @override
  String get quillEmbedValue => '';

  @override
  HideV2TailTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      HideV2TailTag(start: tail!.start, end: tail.end);
}
