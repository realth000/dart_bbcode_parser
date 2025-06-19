import 'dart:convert';

import 'package:dart_bbcode_parser/src/constants.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('abstract basic tag', () {
    test('unused situations', () {
      final tag = buildSingleTag(input: '[b][/b]');
      expect(tag.runtimeType, equals(BoldTag));
      final tagData = {
        'start': 0,
        'end': 7,
        'open': '[',
        'close': ']',
        'name': 'b',
        'selfClosed': false,
        'selfClosedAtTail': false,
        'hasQuillAttr': true,
        'quillAttrName': 'bold',
        'quillAttrValue': true,
        'hasQuillEmbed': false,
        'quillEmbedName': K.unsupported,
        'quillEmbedValue': K.unsupported,
        'target': '${ApplyTarget.text}',
        'attribute': null,
        'children': <dynamic>[],
      };
      expect(tag.toJson(), equals(tagData));
      expect(tag.toString(), equals(jsonEncode(tagData)));
      expect(tag.hashCode.runtimeType, equals(int));
    });
  });
}
