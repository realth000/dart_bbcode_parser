import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('italic tag', () {
    test('without content', () {
      const tag = 'i';
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
        expectedAST: [const ItalicTag(start: 0, end: head.length + content.length + tail.length)],
        expectedDelta: [
          Operation.insert(content, {ItalicTag.empty.quillAttrName: true}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with content', () {
      const tag = 'i';
      const head = '[$tag]';
      const content = 'CONTENT';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: null),
          const Text(start: head.length, end: head.length + content.length, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const ItalicTag(
            start: 0,
            end: head.length + content.length + tail.length,
            children: [TextContent(start: head.length, end: head.length + content.length, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {ItalicTag.empty.quillAttrName: true}),
          Operation.insert('\n'),
        ],
      );
    });

    test('invalid with attribute', () {
      const tag = 'i';
      const attr = 'attr';
      const head = '[$tag=$attr]';
      const content = 'CONTENT';
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
          const TextContent(start: 0, end: head.length, data: head),
          const TextContent(start: head.length, end: head.length + content.length, data: content),
          const TextContent(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            data: tail,
          ),
        ],
        expectedDelta: [
          Operation.insert(head, {}),
          Operation.insert(content, {}),
          Operation.insert(tail, {}),
          Operation.insert('\n'),
        ],
      );
    });
  });
}
