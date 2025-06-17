import 'dart:convert';

import 'package:dart_bbcode_parser/src/tags/hide_v2.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('hide tag', () {
    test('without content', () {
      const tag = 'hide';
      const attr = '1';
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
          const HideV2HeaderTag(start: 0, end: head.length, attribute: attr),
          const HideV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert({
            HideV2HeaderTag.empty.quillEmbedName: jsonEncode({'points': 1}),
          }, {}),
          Operation.insert({HideV2TailTag.empty.quillEmbedName: HideV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with content', () {
      const tag = 'hide';
      const attr = '1';
      const content = 'CONTENT';
      const head = '[$tag=$attr]';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const Text(start: head.length, end: head.length + content.length, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const HideV2HeaderTag(start: 0, end: head.length, attribute: attr),
          const TextContent(start: head.length, end: head.length + content.length, data: content),
          const HideV2TailTag(start: head.length + content.length, end: head.length + content.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert({
            HideV2HeaderTag.empty.quillEmbedName: jsonEncode({'points': 1}),
          }, {}),
          Operation.insert(content, {}),
          Operation.insert({HideV2TailTag.empty.quillEmbedName: HideV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with valid null attribute', () {
      const tag = 'hide';
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
          const HideV2HeaderTag(start: 0, end: head.length, attribute: null),
          const HideV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert({
            HideV2HeaderTag.empty.quillEmbedName: jsonEncode({'points': 0}),
          }, {}),
          Operation.insert({HideV2TailTag.empty.quillEmbedName: HideV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with invalid attribute', () {
      const tag = 'hide';
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
          const TextContent(start: 0, end: head.length, data: head),
          const HideV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert(head, {}),
          Operation.insert({HideV2TailTag.empty.quillEmbedName: HideV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });
  });
}
