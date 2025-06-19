import 'dart:convert';

import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:test/test.dart';

void main() {
  group('lexer only features', () {
    test('unused situations', () {
      const input = '[b]content[/b]';
      final lexer = Lexer(input: input)..scanAll();
      expect(lexer.toBBCode(), equals(input));
    });

    test('complex content', () {
      {
        const input = '[[[b]';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(3));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 1, data: '[')));
        expect(lexer.tokens[1], equals(const Text(start: 1, end: 2, data: '[')));
        expect(lexer.tokens[2], equals(const TagHead(start: 2, end: 5, name: 'b', attribute: null)));
      }

      {
        const input = '[b=]]';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(2));
        expect(lexer.tokens[0], equals(const TagHead(start: 0, end: 4, name: 'b', attribute: '')));
        expect(lexer.tokens[1], equals(const Text(start: 4, end: 5, data: ']')));
      }

      {
        const input = r'[a=\[]';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(1));
        expect(lexer.tokens[0], equals(const TagHead(start: 0, end: 6, name: 'a', attribute: r'\[')));
      }

      {
        const input = '[=]';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(2));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 2, data: '[=')));
        expect(lexer.tokens[1], equals(const Text(start: 2, end: 3, data: ']')));
      }

      {
        const input = '[==1]';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(2));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 2, data: '[=')));
        expect(lexer.tokens[1], equals(const Text(start: 2, end: 5, data: '=1]')));
      }

      {
        const input = '[]';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(1));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 2, data: '[]')));
      }

      {
        const input = '[';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(1));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 1, data: '[')));
      }

      {
        const input = '[a';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(2));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 1, data: '[')));
        expect(lexer.tokens[1], equals(const Text(start: 1, end: 2, data: 'a')));
      }

      {
        const input = '[/';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(1));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 2, data: '[/')));
      }

      {
        const input = '[/';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(1));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 2, data: '[/')));
      }

      {
        const input = '[/]';
        final lexer = Lexer(input: input)..scanAll();
        expect(lexer.tokens.length, equals(1));
        expect(lexer.tokens[0], equals(const Text(start: 0, end: 3, data: '[/]')));
      }
    });

    test('string output', () {
      final lexer = Lexer(input: 'f1[b]f2[i]f3[/i]f4[/b]f5')..scanAll();
      expect(
        jsonDecode(lexer.toString()),
        equals({
          'stage': 'lexer',
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
        }),
      );
    });
  });
}
