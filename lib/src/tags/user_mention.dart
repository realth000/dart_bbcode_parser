import 'dart:convert';

import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// User mention `@$USERNAME`>
class UserMentionTag extends EmbedTag {
  /// Constructor.
  const UserMentionTag({required super.start, required super.end, super.children});

  /// Build empty one.
  static const empty = UserMentionTag(start: -1, end: -1);

  @override
  String get name => '@';

  @override
  AttributeValidator? get attributeValidator => nullAttributeValidator;

  @override
  ChildrenValidator get childrenValidator => (children) => children.every((e) => e.isPlainText);

  @override
  String get quillEmbedName => 'bbcodeUserMention';

  @override
  String get quillEmbedValue => jsonEncode({'name': children.map((e) => e.data).whereType<String>().join()});

  @override
  UserMentionTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      UserMentionTag(start: head!.start, end: tail?.end ?? head.end, children: children);
}
