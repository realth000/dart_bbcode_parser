import 'dart:convert';

import 'package:dart_bbcode_parser/src/constants.dart';
import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:test/test.dart';

void main() {
  group('parser specified cases', () {
    test('complex content', () {
      {
        // [/b]
        final parser = Parser(tokens: [const TagTail(start: 0, end: 1, name: 'b')], supportedTags: defaultSupportedTags)
          ..parse();

        expect(parser.ast.length, equals(1));
        expect(parser.ast[0], equals(const TextContent(start: 0, end: 1, data: '[/b]')));
      }
    });

    test('string output', () {
      // 0    5    10   15   20
      // |    |    |    |    |
      // f1[b]f2[i]f3[/i]f4[/b]f5
      final parser = Parser(
        tokens: [
          // f1: [0, 2)
          const Text(start: 0, end: 2, data: 'f1'),
          // [b]: [2, 5)
          const TagHead(start: 2, end: 5, name: 'b', attribute: null),
          // f2: [5, 7)
          const Text(start: 5, end: 7, data: 'f2'),
          // [i]: [7, 10)
          const TagHead(start: 7, end: 10, name: 'i', attribute: null),
          // f3: [10, 12)
          const Text(start: 10, end: 12, data: 'f3'),
          // [/i]: [12, 16)
          const TagTail(start: 12, end: 16, name: 'i'),
          // f4: [16, 18)
          const Text(start: 16, end: 18, data: 'f4'),
          // [/b]: [18, 22)
          const TagTail(start: 18, end: 22, name: 'b'),
          // f5: [22, 24)
          const Text(start: 22, end: 24, data: 'f5'),
        ],
        supportedTags: defaultSupportedTags,
      )..parse();

      expect(parser.ast.length, equals(3));
      expect(parser.ast[0], equals(const TextContent(start: 0, end: 2, data: 'f1')));
      expect(
        parser.ast[1],
        equals(
          const BoldTag(
            start: 2,
            end: 22,
            children: [
              TextContent(start: 5, end: 7, data: 'f2'),
              ItalicTag(start: 7, end: 15, children: [TextContent(start: 10, end: 12, data: 'f3')]),
              TextContent(start: 16, end: 18, data: 'f4'),
            ],
          ),
        ),
      );
      expect(parser.ast[2], equals(const TextContent(start: 22, end: 24, data: 'f5')));
      expect(
        jsonDecode(parser.toString()),
        equals({
          'stage': 'parser',
          'tokens': [
            {'token': 'Text', 'start': 0, 'end': 2, 'data': 'f1'},
            {'token': 'TagHead', 'start': 2, 'end': 5, 'name': 'b', 'attribute': null},
            {'token': 'Text', 'start': 5, 'end': 7, 'data': 'f2'},
            {'token': 'TagHead', 'start': 7, 'end': 10, 'name': 'i', 'attribute': null},
            {'token': 'Text', 'start': 10, 'end': 12, 'data': 'f3'},
            {'token': 'TagTail', 'start': 12, 'end': 16, 'name': 'i'},
            {'token': 'Text', 'start': 16, 'end': 18, 'data': 'f4'},
            {'token': 'TagTail', 'start': 18, 'end': 22, 'name': 'b'},
            {'token': 'Text', 'start': 22, 'end': 24, 'data': 'f5'},
          ],
          'ast': [
            {'start': 0, 'end': 2, 'text': 'f1'},
            {
              'start': 2,
              'end': 22,
              'open': '[',
              'close': ']',
              'name': 'b',
              'selfClosed': false,
              'selfClosedAtTail': false,
              'hasQuillAttr': true,
              'quillAttrName': 'bold',
              'quillAttrValue': true,
              'hasQuillEmbed': false,
              'quillEmbedName': K.unsupported,
              'quillEmbedValue': K.unsupported,
              'target': 'ApplyTarget.text',
              'attribute': null,
              'children': [
                {'start': 5, 'end': 7, 'text': 'f2'},
                {
                  'start': 7,
                  'end': 16,
                  'open': '[',
                  'close': ']',
                  'name': 'i',
                  'selfClosed': false,
                  'selfClosedAtTail': false,
                  'hasQuillAttr': true,
                  'quillAttrName': 'italic',
                  'quillAttrValue': true,
                  'hasQuillEmbed': false,
                  'quillEmbedName': K.unsupported,
                  'quillEmbedValue': K.unsupported,
                  'target': 'ApplyTarget.text',
                  'attribute': null,
                  'children': [
                    {'start': 10, 'end': 12, 'text': 'f3'},
                  ],
                },
                {'start': 16, 'end': 18, 'text': 'f4'},
              ],
            },
            {'start': 22, 'end': 24, 'text': 'f5'},
          ],
        }),
      );
    });
  });
}
