import 'package:dart_bbcode_parser/src/tags/backgroud_color.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/scaffolding.dart';

import '../utils.dart';

void main() {
  group('background color tag', () {
    test('without content', () {
      const head = '[backcolor=red]';
      const content = '';
      const tail = '[/backcolor]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'backcolor', attribute: 'red'),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'backcolor',
          ),
        ],
        expectedAST: [
          const BackgroundColorTag(start: 0, end: head.length + content.length + tail.length, attribute: 'red'),
        ],
        expectedDelta: [
          Operation.insert('', {'background': 'red'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with content', () {
      const head = '[backcolor=red]';
      const content = 'CONTENT';
      const tail = '[/backcolor]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'backcolor', attribute: 'red'),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'backcolor',
          ),
        ],
        expectedAST: [
          const BackgroundColorTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: 'red',
            children: [TextContent(start: head.length, end: head.length + content.length + 1, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {'background': 'red'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('hex color - 6 digits', () {
      const head = '[backcolor=#ff00ff]';
      const content = 'CONTENT';
      const tail = '[/backcolor]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'backcolor', attribute: '#ff00ff'),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'backcolor',
          ),
        ],
        expectedAST: [
          const BackgroundColorTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: '#ff00ff',
            children: [TextContent(start: head.length, end: head.length + content.length + 1, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {'background': '#ff00ff'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('hex color - 3 digits', () {
      const head = '[backcolor=#abc]';
      const content = 'CONTENT';
      const tail = '[/backcolor]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'backcolor', attribute: '#abc'),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'backcolor',
          ),
        ],
        expectedAST: [
          const BackgroundColorTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: '#aabbcc',
            children: [TextContent(start: head.length, end: head.length + content.length + 1, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {'background': '#abc'}),
          Operation.insert('\n'),
        ],
      );
    });

    test('invalid color value (8 digits with alpha channel)', () {
      const head = '[backcolor=#ffaabbcc]';
      const content = 'CONTENT';
      const tail = '[/backcolor]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'backcolor', attribute: '#ffaabbcc'),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'backcolor',
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
