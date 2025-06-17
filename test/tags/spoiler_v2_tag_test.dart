import 'dart:convert';

import 'package:dart_bbcode_parser/src/tags/spoiler_v2.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('spoiler tag', () {
    test('without content', () {
      const tag = 'spoiler';
      const attr = 'attr';
      const head = '[$tag=$attr]';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: '',
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const TagTail(start: head.length, end: head.length + tail.length, name: tag),
        ],
        expectedAST: [
          const SpoilerV2HeaderTag(start: 0, end: head.length, attribute: attr),
          const SpoilerV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert({
            SpoilerV2HeaderTag.empty.quillEmbedName: jsonEncode({'title': attr}),
          }, {}),
          Operation.insert({SpoilerV2TailTag.empty.quillEmbedName: SpoilerV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with invalid attribute', () {
      const tag = 'spoiler';
      const attr = '';
      const head = '[$tag=$attr]';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: '',
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const TagTail(start: head.length, end: head.length + tail.length, name: tag),
        ],
        expectedAST: [
          const TextContent(start: 0, end: head.length, data: head),
          const SpoilerV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert(head, {}),
          Operation.insert({SpoilerV2TailTag.empty.quillEmbedName: SpoilerV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with null attribute', () {
      const tag = 'spoiler';
      const head = '[$tag]';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: '',
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: null),
          const TagTail(start: head.length, end: head.length + tail.length, name: tag),
        ],
        expectedAST: [
          const TextContent(start: 0, end: head.length, data: head),
          const SpoilerV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert(head, {}),
          Operation.insert({SpoilerV2TailTag.empty.quillEmbedName: SpoilerV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });
  });
}
