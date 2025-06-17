import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/expect.dart';

void checkSingleTag({
  required String head,
  required String content,
  required String tail,
  required List<Token> expectedTokens,
  required List<BBCodeTag> expectedAST,
  required List<Operation> expectedDelta,
  List<BBCodeTag> supportedTags = defaultSupportedTags,
  bool checkTokens = true,
  bool checkAST = true,
  bool checkDelta = true,
  bool checkBBCode = true,
}) {
  final input = '$head$content$tail';

  // Tokens stage.
  final lexer = Lexer(input: input)..scanAll();
  final tokens = lexer.tokens;
  if (checkTokens) {
    expect(tokens, equals(expectedTokens), reason: 'tokens not match as expected');
  }

  // AST stage.
  final parser = Parser(tokens: tokens, supportedTags: supportedTags)..parse();
  final ast = parser.ast;
  if (checkAST) {
    expect(ast, equals(expectedAST), reason: 'AST not match as expected');
  }

  // Delta stage.
  final delta = buildDelta(ast);
  final targetDelta = Delta.fromOperations(expectedDelta);
  if (checkDelta) {
    expect(delta.toJson(), equals(targetDelta.toJson()), reason: 'delta not match as expected');
  }

  // Back to BBCode stage.
  if (checkBBCode) {
    expect(convertBBCodeToText(ast), equals(input), reason: 'BBCode not match as expected');
  }
}
