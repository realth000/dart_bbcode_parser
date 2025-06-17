import 'package:dart_bbcode_parser/src/tags/code.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('code tag', () {
    test('without content', () {
      const tag = 'code';
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
        expectedAST: [const CodeTag(start: 0, end: head.length + content.length + tail.length)],
        expectedDelta: [
          Operation.insert('', {}),
          Operation.insert('\n', {CodeTag.empty.quillAttrName: CodeTag.empty.quillAttrValue}),
        ],
      );
    });

    test('with text content', () {
      const tag = 'code';
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
          const CodeTag(
            start: 0,
            end: head.length + content.length + tail.length,
            children: [TextContent(start: head.length, end: head.length + content.length, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {}),
          Operation.insert('\n', {CodeTag.empty.quillAttrName: CodeTag.empty.quillAttrValue}),
        ],
      );
    });

    test('with tag content', () {
      const tag = 'code';
      const head = '[$tag]';
      const content = '[b]CONTENT[/b]';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: null),
          const TagHead(start: head.length, end: head.length + 3, name: 'b', attribute: null),
          const Text(start: head.length + 3, end: head.length + 3 + 'CONTENT'.length, data: 'CONTENT'),
          const TagTail(
            start: head.length + 3 + 'CONTENT'.length,
            end: head.length + 3 + 'CONTENT'.length + 4,
            name: 'b',
          ),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const CodeTag(
            start: 0,
            end: head.length + content.length + tail.length,
            children: [TextContent(start: head.length, end: head.length + content.length, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {}),
          Operation.insert('\n', {CodeTag.empty.quillAttrName: CodeTag.empty.quillAttrValue}),
        ],
      );
    });

    test('nested code content', () {
      const tag = 'code';
      const head = '[$tag]';
      const content = '[$tag]CONTENT[/$tag]';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: null),
          const TagHead(start: head.length, end: head.length + head.length, name: tag, attribute: null),
          const Text(
            start: head.length + head.length,
            end: head.length + head.length + 'CONTENT'.length,
            data: 'CONTENT',
          ),
          const TagTail(
            start: head.length + head.length + 'CONTENT'.length,
            end: head.length + content.length,
            name: tag,
          ),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const CodeTag(
            start: 0,
            end: head.length + content.length + tail.length,
            children: [TextContent(start: head.length, end: head.length + content.length, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {}),
          Operation.insert('\n', {CodeTag.empty.quillAttrName: CodeTag.empty.quillAttrValue}),
        ],
      );
    });

    test('invalid with attribute', () {
      const tag = 'code';
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
