import 'dart:convert';

import 'package:dart_bbcode_parser/src/constants.dart';
import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/tags/underline.dart';
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

      {
        // [b]
        final parser = Parser(
          tokens: [const TagHead(start: 0, end: 1, name: 'b', attribute: null)],
          supportedTags: defaultSupportedTags,
        )..parse();

        expect(parser.ast.length, equals(1));
        expect(parser.ast[0], equals(const TextContent(start: 0, end: 1, data: '[b]')));
      }

      {
        // foo[b]
        final parser = Parser(
          tokens: [
            const Text(start: 0, end: 3, data: 'foo'),
            const TagHead(start: 3, end: 6, name: 'b', attribute: null),
          ],
          supportedTags: defaultSupportedTags,
        )..parse();

        expect(parser.ast.length, equals(2));
        expect(parser.ast[0], equals(const TextContent(start: 0, end: 3, data: 'foo')));
        expect(parser.ast[1], equals(const TextContent(start: 3, end: 6, data: '[b]')));
      }

      {
        // [b]foo
        final parser = Parser(
          tokens: [
            const TagHead(start: 0, end: 3, name: 'b', attribute: null),
            const Text(start: 3, end: 6, data: 'foo'),
          ],
          supportedTags: defaultSupportedTags,
        )..parse();

        expect(parser.ast.length, equals(2));
        expect(parser.ast[0], equals(const TextContent(start: 0, end: 3, data: '[b]')));
        expect(parser.ast[1], equals(const TextContent(start: 3, end: 6, data: 'foo')));
      }

      {
        // foo[/b]
        final parser = Parser(
          tokens: [const Text(start: 0, end: 3, data: 'foo'), const TagTail(start: 3, end: 7, name: 'b')],
          supportedTags: defaultSupportedTags,
        )..parse();

        expect(parser.ast.length, equals(2));
        expect(parser.ast[0], equals(const TextContent(start: 0, end: 3, data: 'foo')));
        expect(parser.ast[1], equals(const TextContent(start: 3, end: 7, data: '[/b]')));
      }

      {
        // [/b]foo
        final parser = Parser(
          tokens: [const TagTail(start: 0, end: 4, name: 'b'), const Text(start: 4, end: 7, data: 'foo')],
          supportedTags: defaultSupportedTags,
        )..parse();

        expect(parser.ast.length, equals(2));
        expect(parser.ast[0], equals(const TextContent(start: 0, end: 4, data: '[/b]')));
        expect(parser.ast[1], equals(const TextContent(start: 4, end: 7, data: 'foo')));
      }
    });

    test('string output', () {
      // 0    5    10   15   20   25   30
      // |    |    |    |    |    |    |
      // [u]text[/u]f1[b]f2[i]f3[/i]f4[/b]f5
      final parser = Parser(
        tokens: [
          // [u]: [0, 3)
          const TagHead(start: 0, end: 3, name: 'u', attribute: null),
          // text: [3, 7)
          const Text(start: 3, end: 7, data: 'text'),
          // [/u]: [7, 11)
          const TagTail(start: 7, end: 11, name: 'u'),
          // f1: [11, 13)
          const Text(start: 11, end: 13, data: 'f1'),
          // [b]: [13, 16)
          const TagHead(start: 13, end: 16, name: 'b', attribute: null),
          // f2: [16, 18)
          const Text(start: 16, end: 18, data: 'f2'),
          // [i]: [18, 21)
          const TagHead(start: 18, end: 21, name: 'i', attribute: null),
          // f3: [21, 23)
          const Text(start: 21, end: 23, data: 'f3'),
          // [/i]: [23, 27)
          const TagTail(start: 23, end: 27, name: 'i'),
          // f4: [27, 29)
          const Text(start: 27, end: 29, data: 'f4'),
          // [/b]: [29, 33)
          const TagTail(start: 29, end: 33, name: 'b'),
          // f5: [33, 35)
          const Text(start: 33, end: 35, data: 'f5'),
        ],
        supportedTags: defaultSupportedTags,
      )..parse();

      expect(parser.ast.length, equals(4));
      expect(
        parser.ast[0],
        equals(const UnderlineTag(start: 0, end: 3, children: [TextContent(start: 3, end: 7, data: 'text')])),
      );
      expect(parser.ast[1], equals(const TextContent(start: 11, end: 13, data: 'f1')));
      expect(
        parser.ast[2],
        equals(
          const BoldTag(
            start: 13,
            end: 33,
            children: [
              TextContent(start: 16, end: 18, data: 'f2'),
              ItalicTag(start: 18, end: 26, children: [TextContent(start: 21, end: 23, data: 'f3')]),
              TextContent(start: 27, end: 29, data: 'f4'),
            ],
          ),
        ),
      );
      expect(parser.ast[3], equals(const TextContent(start: 33, end: 35, data: 'f5')));
      expect(
        jsonDecode(parser.toString()),
        equals({
          'stage': 'parser',
          'tokens': [
            {'token': 'TagHead', 'start': 0, 'end': 3, 'name': 'u', 'attribute': null},
            {'token': 'Text', 'start': 3, 'end': 7, 'data': 'text'},
            {'token': 'TagTail', 'start': 7, 'end': 11, 'name': 'u'},
            {'token': 'Text', 'start': 11, 'end': 13, 'data': 'f1'},
            {'token': 'TagHead', 'start': 13, 'end': 16, 'name': 'b', 'attribute': null},
            {'token': 'Text', 'start': 16, 'end': 18, 'data': 'f2'},
            {'token': 'TagHead', 'start': 18, 'end': 21, 'name': 'i', 'attribute': null},
            {'token': 'Text', 'start': 21, 'end': 23, 'data': 'f3'},
            {'token': 'TagTail', 'start': 23, 'end': 27, 'name': 'i'},
            {'token': 'Text', 'start': 27, 'end': 29, 'data': 'f4'},
            {'token': 'TagTail', 'start': 29, 'end': 33, 'name': 'b'},
            {'token': 'Text', 'start': 33, 'end': 35, 'data': 'f5'},
          ],
          'ast': [
            {
              'start': 0,
              'end': 11,
              'open': '[',
              'close': ']',
              'name': 'u',
              'selfClosed': false,
              'selfClosedAtTail': false,
              'hasQuillAttr': true,
              'quillAttrName': 'underline',
              'quillAttrValue': true,
              'hasQuillEmbed': false,
              'quillEmbedName': K.unsupported,
              'quillEmbedValue': K.unsupported,
              'target': 'ApplyTarget.text',
              'attribute': null,
              'children': [
                {'start': 3, 'end': 7, 'text': 'text'},
              ],
            },
            {'start': 11, 'end': 13, 'text': 'f1'},
            {
              'start': 13,
              'end': 33,
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
                {'start': 16, 'end': 18, 'text': 'f2'},
                {
                  'start': 18,
                  'end': 27,
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
                    {'start': 21, 'end': 23, 'text': 'f3'},
                  ],
                },
                {'start': 27, 'end': 29, 'text': 'f4'},
              ],
            },
            {'start': 33, 'end': 35, 'text': 'f5'},
          ],
        }),
      );
    });

    test('maybe rotating AST', () {
      // 0    5    10   15   20
      // |    |    |    |    |
      // x[b][i]i[/i][u]u[/u][/b]
      final parser = Parser(
        tokens: [
          // x: [0, 1)
          const Text(start: 0, end: 1, data: 'x'),
          // [b]: [1, 4)
          const TagHead(start: 1, end: 4, name: 'b', attribute: null),
          // [i]: [4, 7)
          const TagHead(start: 4, end: 7, name: 'i', attribute: null),
          // i: [7, 8)
          const Text(start: 7, end: 8, data: 'i'),
          // [/i]: [8, 12)
          const TagTail(start: 8, end: 12, name: 'i'),
          // [u]: [12, 15)
          const TagHead(start: 12, end: 15, name: 'u', attribute: null),
          // u: [15, 16)
          const Text(start: 15, end: 16, data: 'u'),
          // [/u]: [16, 20)
          const TagTail(start: 16, end: 20, name: 'u'),
          // [/b]: [20, 24)
          const TagTail(start: 20, end: 24, name: 'b'),
        ],
        supportedTags: defaultSupportedTags,
      )..parse();

      expect(parser.ast.length, equals(2));
      expect(parser.ast[0], equals(const TextContent(start: 0, end: 1, data: 'x')));
      expect(
        parser.ast[1],
        equals(
          const BoldTag(
            start: 1,
            end: 24,
            children: [
              ItalicTag(start: 4, end: 12, children: [TextContent(start: 7, end: 8, data: 'i')]),
              UnderlineTag(start: 12, end: 20, children: [TextContent(start: 15, end: 16, data: 'u')]),
            ],
          ),
        ),
      );
    });
  });

  group('parser context specified cases', () {
    test('invalid operations', () {
      {
        final pc = ParseContext();
        expect(() => pc.leaveScope(const TagTail(start: 0, end: 0, name: 'b')), throwsUnsupportedError);
      }
    });
  });
}
