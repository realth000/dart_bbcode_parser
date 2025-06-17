import 'dart:convert';

import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// Free v2 tag header in bbcode editor.
class FreeV2HeaderTag extends EmbedTag {
  /// Constructor.
  const FreeV2HeaderTag({required super.start, required super.end});

  /// Build empty one.
  static const empty = FreeV2HeaderTag(start: -1, end: -1);

  @override
  String get name => 'free';

  @override
  AttributeValidator? get attributeValidator => nullAttributeValidator;

  @override
  String get quillEmbedName => 'bbcodeFreeHeader';

  @override
  bool get selfClosed => true;

  @override
  String get quillEmbedValue => jsonEncode({});

  @override
  FreeV2HeaderTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      FreeV2HeaderTag(start: head!.start, end: tail?.end ?? head.end);
}

/// Free v2 tag tail in bbcode editor.
class FreeV2TailTag extends EmbedTag {
  /// Constructor.
  const FreeV2TailTag({required super.start, required super.end});

  /// Build empty one.
  static const empty = FreeV2TailTag(start: -1, end: -1);

  @override
  String get name => 'free';

  @override
  bool get selfClosed => true;

  @override
  bool get selfClosedAtTail => true;

  @override
  String get quillEmbedName => 'bbcodeFreeTail';

  @override
  String get quillEmbedValue => jsonEncode({});

  @override
  FreeV2TailTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      FreeV2TailTag(start: tail!.start, end: tail.end);
}
