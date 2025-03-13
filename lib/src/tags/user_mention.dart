import 'dart:convert';

import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// User mention `@$USERNAME`>
class UserMentionTag extends EmbedTag {
  /// Constructor.
  const UserMentionTag({super.children});

  @override
  String get name => '@';

  @override
  ChildrenValidator get childrenValidator => (children) => children.every((e) => e.isPlainText);

  @override
  String get quillEmbedName => 'bbcodeUserMention';

  @override
  String get quillEmbedValue =>
    jsonEncode({
      'name': children!.map((e) => e.data).whereType<String>().join(),
    });

  @override
  UserMentionTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) => UserMentionTag(children: children);
}
