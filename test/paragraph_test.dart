import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  group('paragraph node test', () {
    test('ignore next line feed after the last paragraph tag', () {
      checkMultipleTags(
        input: '[align=center]foo[/align]\n[align=left]bar[/align]baz\nquz',
        expectedTokens: [
          const TagHead(start: 0, end: 14, name: 'align', attribute: 'center'),
          const Text(start: 14, end: 17, data: 'foo'),
          const TagTail(start: 17, end: 25, name: 'align'),
          const Text(start: 25, end: 26, data: '\n'),
          const TagHead(start: 26, end: 38, name: 'align', attribute: 'left'),
          const Text(start: 38, end: 41, data: 'bar'),
          const TagTail(start: 41, end: 49, name: 'align'),
          const Text(start: 49, end: 56, data: 'baz\nquz'),
        ],
        expectedAST: [
          AlignTag(start: 0, end: 25, attribute: 'center', children: [TextContent(start: 14, end: 17, data: 'foo')]),
          TextContent(start: 25, end: 26, data: '\n', isIgnored: true),
          AlignTag(start: 27, end: 49, attribute: 'left', children: [TextContent(start: 38, end: 41, data: 'bar')]),
          TextContent(start: 49, end: 56, data: 'baz\nquz'),
        ],
        expectedDelta: [
          Operation.insert('foo', {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'center'}),
          Operation.insert('bar', {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'left'}),
          Operation.insert('baz\nquz', {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('produce content when no line feed after the last paragraph tag', () {
      checkMultipleTags(
        input: '[align=center]foo[/align][align=left]bar[/align]baz\nquz',
        expectedTokens: [
          const TagHead(start: 0, end: 14, name: 'align', attribute: 'center'),
          const Text(start: 14, end: 17, data: 'foo'),
          const TagTail(start: 17, end: 25, name: 'align'),
          const TagHead(start: 25, end: 37, name: 'align', attribute: 'left'),
          const Text(start: 37, end: 40, data: 'bar'),
          const TagTail(start: 40, end: 48, name: 'align'),
          const Text(start: 48, end: 55, data: 'baz\nquz'),
        ],
        expectedAST: [
          AlignTag(start: 0, end: 25, attribute: 'center', children: [TextContent(start: 14, end: 17, data: 'foo')]),
          AlignTag(start: 25, end: 48, attribute: 'left', children: [TextContent(start: 37, end: 40, data: 'bar')]),
          TextContent(start: 48, end: 55, data: 'baz\nquz'),
        ],
        expectedDelta: [
          Operation.insert('foo', {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'center'}),
          Operation.insert('bar', {}),
          Operation.insert('\n', {AlignTag.empty.quillAttrName: 'left'}),
          Operation.insert('baz\nquz', {}),
          Operation.insert('\n'),
        ],
      );
    });
  });
}
