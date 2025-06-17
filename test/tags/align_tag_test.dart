import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

void main() {
  group('align center tag', () {
    test('without content', () {
      const input = '[align=center][/align]';
      final lexer = Lexer(input: input)..scanAll();
      final tokens = lexer.tokens;
      expect(tokens.length, 2);
      expect(tokens[0], const TagHead(start: 0, end: 14, name: 'align', attribute: 'center'));
      expect(tokens[1], const TagTail(start: 14, end: 22, name: 'align'));

      final parser = Parser(tokens: tokens, supportedTags: defaultSupportedTags)..parse();
      final ast = parser.ast;
      expect(ast.length, 1);
      expect(ast[0], const AlignTag(start: 0, end: 22, attribute: 'center'));

      final quillDelta = buildDelta(ast);
      final targetDelta = Delta.fromOperations([
        Operation.insert('', {}),
        Operation.insert('\n', {'align': 'center'}),
      ]);
      expect(quillDelta.toJson(), targetDelta.toJson());

      expect(convertBBCodeToText(ast), input);
    });

    test('with content', () {
      const content = 'CONTENT';
      const input = '[align=center]$content[/align]';
      final lexer = Lexer(input: input)..scanAll();
      final tokens = lexer.tokens;
      expect(tokens.length, 3);
      expect(tokens[0], const TagHead(start: 0, end: 14, name: 'align', attribute: 'center'));
      expect(tokens[1].tokenType, TokenType.text);
      expect(tokens[2], const TagTail(start: 14 + content.length, end: 22 + content.length, name: 'align'));

      final parser = Parser(tokens: tokens, supportedTags: defaultSupportedTags)..parse();
      final ast = parser.ast;
      expect(ast.length, 1);
      expect(
        ast[0],
        const AlignTag(
          start: 0,
          end: 22 + content.length,
          attribute: 'center',
          children: [TextContent(14, 14 + content.length + 1, content)],
        ),
      );

      final quillDelta = buildDelta(ast);
      final targetDelta = Delta.fromOperations([
        Operation.insert(content, {}),
        Operation.insert('\n', {'align': 'center'}),
      ]);
      expect(quillDelta.toJson(), targetDelta.toJson());

      expect(convertBBCodeToText(ast), input);
    });
  });

  group('align left tag', () {
    test('without content', () {
      const input = '[align=left][/align]';
      final lexer = Lexer(input: input)..scanAll();
      final tokens = lexer.tokens;
      expect(tokens.length, 2);
      expect(tokens[0], const TagHead(start: 0, end: 12, name: 'align', attribute: 'left'));
      expect(tokens[1], const TagTail(start: 12, end: 20, name: 'align'));

      final parser = Parser(tokens: tokens, supportedTags: defaultSupportedTags)..parse();
      final ast = parser.ast;
      expect(ast.length, 1);
      expect(ast[0], const AlignTag(start: 0, end: 20, attribute: 'left'));

      final quillDelta = buildDelta(ast);
      final targetDelta = Delta.fromOperations([
        Operation.insert('', {}),
        Operation.insert('\n', {'align': 'left'}),
      ]);
      expect(quillDelta.toJson(), targetDelta.toJson());

      expect(convertBBCodeToText(ast), input);
    });

    test('with content', () {
      const content = 'CONTENT';
      const input = '[align=left]$content[/align]';
      final lexer = Lexer(input: input)..scanAll();
      final tokens = lexer.tokens;
      expect(tokens.length, 3);
      expect(tokens[0], const TagHead(start: 0, end: 12, name: 'align', attribute: 'left'));
      expect(tokens[1].tokenType, TokenType.text);
      expect(tokens[2], const TagTail(start: 12 + content.length, end: 20 + content.length, name: 'align'));

      final parser = Parser(tokens: tokens, supportedTags: defaultSupportedTags)..parse();
      final ast = parser.ast;
      expect(ast.length, 1);
      expect(
        ast[0],
        const AlignTag(
          start: 0,
          end: 20 + content.length,
          attribute: 'left',
          children: [TextContent(12, 12 + content.length + 1, content)],
        ),
      );

      final quillDelta = buildDelta(ast);
      final targetDelta = Delta.fromOperations([
        Operation.insert(content, {}),
        Operation.insert('\n', {'align': 'left'}),
      ]);
      expect(quillDelta.toJson(), targetDelta.toJson());

      expect(convertBBCodeToText(ast), input);
    });
  });

  group('align right tag', () {
    test('without content', () {
      const input = '[align=right][/align]';
      final lexer = Lexer(input: input)..scanAll();
      final tokens = lexer.tokens;
      expect(tokens.length, 2);
      expect(tokens[0], const TagHead(start: 0, end: 13, name: 'align', attribute: 'right'));
      expect(tokens[1], const TagTail(start: 13, end: 21, name: 'align'));

      final parser = Parser(tokens: tokens, supportedTags: defaultSupportedTags)..parse();
      final ast = parser.ast;
      expect(ast.length, 1);
      expect(ast[0], const AlignTag(start: 0, end: 21, attribute: 'right'));

      final quillDelta = buildDelta(ast);
      final targetDelta = Delta.fromOperations([
        Operation.insert('', {}),
        Operation.insert('\n', {'align': 'right'}),
      ]);
      expect(quillDelta.toJson(), targetDelta.toJson());

      expect(convertBBCodeToText(ast), input);
    });

    test('with content', () {
      const content = 'CONTENT';
      const input = '[align=right]$content[/align]';
      final lexer = Lexer(input: input)..scanAll();
      final tokens = lexer.tokens;
      expect(tokens.length, 3);
      expect(tokens[0], const TagHead(start: 0, end: 13, name: 'align', attribute: 'right'));
      expect(tokens[1].tokenType, TokenType.text);
      expect(tokens[2], const TagTail(start: 13 + content.length, end: 21 + content.length, name: 'align'));

      final parser = Parser(tokens: tokens, supportedTags: defaultSupportedTags)..parse();
      final ast = parser.ast;
      expect(ast.length, 1);
      expect(
        ast[0],
        const AlignTag(
          start: 0,
          end: 21 + content.length,
          attribute: 'right',
          children: [TextContent(13, 13 + content.length + 1, content)],
        ),
      );

      final quillDelta = buildDelta(ast);
      final targetDelta = Delta.fromOperations([
        Operation.insert(content, {}),
        Operation.insert('\n', {'align': 'right'}),
      ]);
      expect(quillDelta.toJson(), targetDelta.toJson());

      expect(convertBBCodeToText(ast), input);
    });
  });
}
