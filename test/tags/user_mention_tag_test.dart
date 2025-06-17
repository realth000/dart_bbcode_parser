import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('user mention tag', () {
    test('with empty content', () {
      const tag = 'img';
      const width = 100;
      const height = 200;
      const attr = '$width,$height';
      const head = '[$tag=$attr]';
      const content = '';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const TextContent(start: 0, end: head.length, data: head),
          const TextContent(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            data: tail,
          ),
        ],
        expectedDelta: [Operation.insert(head, {}), Operation.insert(tail, {}), Operation.insert('\n')],
      );
    });

    test('with invalid attribute', () {
      const tag = 'img';
      const attr = 'attribute';
      const head = '[$tag=$attr]';
      const content = '';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const TextContent(start: 0, end: head.length, data: head),
          const TextContent(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            data: tail,
          ),
        ],
        expectedDelta: [Operation.insert(head, {}), Operation.insert(tail, {}), Operation.insert('\n')],
      );
    });

    test('with null attribute', () {
      const tag = 'img';
      const head = '[$tag]';
      const content = '';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: null),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const TextContent(start: 0, end: head.length, data: head),
          const TextContent(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            data: tail,
          ),
        ],
        expectedDelta: [Operation.insert(head, {}), Operation.insert(tail, {}), Operation.insert('\n')],
      );
    });
  });
}
