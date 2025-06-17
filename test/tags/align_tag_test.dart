import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('align center tag', () {
    test('without content', () {
      const head = '[align=center]';
      const content = '';
      const tail = '[/align]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'align', attribute: 'center'),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'align',
          ),
        ],
        expectedBBCodeTags: [
          const AlignTag(start: 0, end: head.length + content.length + tail.length, attribute: 'center'),
        ],
        expectedOperations: [
          Operation.insert('', {}),
          Operation.insert('\n', {'align': 'center'}),
        ],
      );
    });

    test('with content', () {
      const head = '[align=center]';
      const content = 'CONTENT';
      const tail = '[/align]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'align', attribute: 'center'),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'align',
          ),
        ],
        expectedBBCodeTags: [
          const AlignTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: 'center',
            children: [TextContent(head.length, head.length + content.length + 1, content)],
          ),
        ],
        expectedOperations: [
          Operation.insert(content, {}),
          Operation.insert('\n', {'align': 'center'}),
        ],
      );
    });
  });

  group('align left tag', () {
    test('without content', () {
      const head = '[align=left]';
      const content = '';
      const tail = '[/align]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'align', attribute: 'left'),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'align',
          ),
        ],
        expectedBBCodeTags: [
          const AlignTag(start: 0, end: head.length + content.length + tail.length, attribute: 'left'),
        ],
        expectedOperations: [
          Operation.insert('', {}),
          Operation.insert('\n', {'align': 'left'}),
        ],
      );
    });

    test('with content', () {
      const head = '[align=left]';
      const content = 'CONTENT';
      const tail = '[/align]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'align', attribute: 'left'),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'align',
          ),
        ],
        expectedBBCodeTags: [
          const AlignTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: 'left',
            children: [TextContent(head.length, head.length + content.length + 1, content)],
          ),
        ],
        expectedOperations: [
          Operation.insert(content, {}),
          Operation.insert('\n', {'align': 'left'}),
        ],
      );
    });
  });

  group('align right tag', () {
    test('without content', () {
      const head = '[align=right]';
      const content = '';
      const tail = '[/align]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'align', attribute: 'right'),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'align',
          ),
        ],
        expectedBBCodeTags: [
          const AlignTag(start: 0, end: head.length + content.length + tail.length, attribute: 'right'),
        ],
        expectedOperations: [
          Operation.insert('', {}),
          Operation.insert('\n', {'align': 'right'}),
        ],
      );
    });

    test('with content', () {
      const head = '[align=right]';
      const content = 'CONTENT';
      const tail = '[/align]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: 'align', attribute: 'right'),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: 'align',
          ),
        ],
        expectedBBCodeTags: [
          const AlignTag(
            start: 0,
            end: head.length + content.length + tail.length,
            attribute: 'right',
            children: [TextContent(head.length, head.length + content.length + 1, content)],
          ),
        ],
        expectedOperations: [
          Operation.insert(content, {}),
          Operation.insert('\n', {'align': 'right'}),
        ],
      );
    });
  });
}
