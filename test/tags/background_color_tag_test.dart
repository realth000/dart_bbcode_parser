import 'package:dart_bbcode_parser/src/tags/backgroud_color.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/scaffolding.dart';

import '../utils.dart';

void main() {
  group('background color tag', () {
    test('without content', () {
      const tag = 'backcolor';
      const attr = 'red';
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
          const BackgroundColorTag(start: 0, end: head.length + content.length + tail.length, attribute: attr),
        ],
        expectedDelta: [
          Operation.insert('', {BackgroundColorTag.empty.quillAttrName: 'red'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with content', () {
      const tag = 'backcolor';
      const attr = 'red';
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
          const BackgroundColorTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: attr,
            children: [TextContent(start: head.length, end: head.length + content.length, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {BackgroundColorTag.empty.quillAttrName: 'red'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('hex color - 6 digits', () {
      const tag = 'backcolor';
      const attr = '#ff00ff';
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
          const BackgroundColorTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: attr,
            children: [TextContent(start: head.length, end: head.length + content.length, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {BackgroundColorTag.empty.quillAttrName: '#ff00ff'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('hex color - 3 digits', () {
      const tag = 'backcolor';
      const attr = '#abc';
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
          const BackgroundColorTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: '#aabbcc',
            children: [TextContent(start: head.length, end: head.length + content.length, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {BackgroundColorTag.empty.quillAttrName: '#abc'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('invalid color value (8 digits with alpha channel)', () {
      const tag = 'backcolor';
      const attr = '#ffaabbcc';
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

  test('without attribute', () {
    const tag = 'backcolor';
    const head = '[$tag]';
    const content = '';
    const tail = '[/$tag]';
    checkSingleTag(
      head: head,
      content: content,
      tail: tail,
      expectedTokens: [
        const TagHead(start: 0, end: head.length, name: tag, attribute: null),
        const TagTail(start: head.length + content.length, end: head.length + content.length + tail.length, name: tag),
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
}
