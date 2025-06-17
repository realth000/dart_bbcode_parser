import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('align center tag', () {
    test('without content', () {
      const tag = 'align';
      const attr = 'center';
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
        expectedAST: [const AlignTag(start: 0, end: head.length + content.length + tail.length, attribute: attr)],
        expectedDelta: [
          Operation.insert('', {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'center'}),
        ],
      );
    });

    test('with content', () {
      const tag = 'align';
      const attr = 'center';
      const head = '[$tag=$attr]';
      const content = 'CONTENT';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const AlignTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: attr,
            children: [TextContent(start: head.length, end: head.length + content.length + 1, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'center'}),
        ],
      );
    });
  });

  group('align left tag', () {
    test('without content', () {
      const tag = 'align';
      const attr = 'left';
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
        expectedAST: [const AlignTag(start: 0, end: head.length + content.length + tail.length, attribute: attr)],
        expectedDelta: [
          Operation.insert('', {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'left'}),
        ],
      );
    });

    test('with content', () {
      const tag = 'align';
      const attr = 'left';
      const head = '[$tag=$attr]';
      const content = 'CONTENT';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const AlignTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: attr,
            children: [TextContent(start: head.length, end: head.length + content.length + 1, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'left'}),
        ],
      );
    });
  });

  group('align right tag', () {
    test('without content', () {
      const tag = 'align';
      const attr = 'right';
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
        expectedAST: [const AlignTag(start: 0, end: head.length + content.length + tail.length, attribute: 'right')],
        expectedDelta: [
          Operation.insert('', {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'right'}),
        ],
      );
    });

    test('with content', () {
      const tag = 'align';
      const attr = 'right';
      const head = '[$tag=$attr]';
      const content = 'CONTENT';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const AlignTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: attr,
            children: [TextContent(start: head.length, end: head.length + content.length + 1, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'right'}),
        ],
      );
    });
  });

  group('invalid alignment', () {
    test('without content', () {
      const tag = 'align';
      const attr = 'INVALID_ALIGNMENT';
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
          const TextContent(start: 0, end: head.length + content.length, data: head),
          const TextContent(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            data: tail,
          ),
        ],
        expectedDelta: [Operation.insert(head, {}), Operation.insert(tail, {}), Operation.insert('\n')],
      );
    });

    test('with content', () {
      const tag = 'align';
      const attr = 'INVALID_ALIGNMENT';
      const head = '[$tag=$attr]';
      const content = 'CONTENT';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: attr),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const TextContent(start: 0, end: head.length, data: head),
          const TextContent(start: head.length, end: head.length + content.length + 1, data: content),
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
