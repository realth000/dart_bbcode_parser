import 'package:dart_bbcode_parser/src/tags/free_v2.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('free tag', () {
    test('without content', () {
      const tag = 'free';
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
          const FreeV2HeaderTag(start: 0, end: head.length),
          const FreeV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert({FreeV2HeaderTag.empty.quillEmbedName: FreeV2HeaderTag.empty.quillEmbedValue}, {}),
          Operation.insert({FreeV2TailTag.empty.quillEmbedName: FreeV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with invalid attribute', () {
      const tag = 'free';
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
          const FreeV2TailTag(start: head.length, end: head.length + tail.length),
        ],
        expectedDelta: [
          Operation.insert(head, {}),
          Operation.insert({FreeV2TailTag.empty.quillEmbedName: FreeV2TailTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });
  });
}
