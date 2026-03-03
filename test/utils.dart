import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser_v1.dart';
import 'package:dart_bbcode_parser/src/parser_v2.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/expect.dart';

class TestEnv {
  static final BBCodeParserVersion parserVersion = _loadParserVersion();

  static BBCodeParserVersion _loadParserVersion() {
    final versionInput = int.tryParse(Platform.environment['DBP_PARSER_VERSION'] ?? '1') ?? 1;
    final version =
        BBCodeParserVersion.values.firstWhereOrNull((v) => v.index + 1 == versionInput) ?? BBCodeParserVersion.v1;
    // Fine in testing.
    // ignore: avoid_print
    print('loadParserVersion: using $version');
    return version;
  }
}

BBCodeTag buildSingleTag({required String input, List<BBCodeTag>? supportedTags}) {
  final ss = supportedTags ?? defaultSupportedTags;
  final lexer = Lexer(input: input)..scanAll();
  final parserVersion = TestEnv.parserVersion;
  final parser = switch (parserVersion) {
    BBCodeParserVersion.v1 => ParserV1(tokens: lexer.tokens, supportedTags: ss),
    BBCodeParserVersion.v2 => ParserV2(originalString: input, tokens: lexer.tokens, supportedTags: ss),
  }..parse();
  return parser.ast[0];
}

List<BBCodeTag> buildMultipleTags({required String input, List<BBCodeTag>? supportedTags}) {
  final ss = supportedTags ?? defaultSupportedTags;
  final lexer = Lexer(input: input)..scanAll();
  final parserVersion = TestEnv.parserVersion;
  final parser = switch (parserVersion) {
    BBCodeParserVersion.v1 => ParserV1(tokens: lexer.tokens, supportedTags: ss),
    BBCodeParserVersion.v2 => ParserV2(originalString: input, tokens: lexer.tokens, supportedTags: ss),
  }..parse();
  return parser.ast;
}

void checkSingleTag({
  required String head,
  required String content,
  required String tail,
  required List<Token> expectedTokens,
  required List<BBCodeTag> expectedAST,
  required List<Operation> expectedDelta,
  List<BBCodeTag>? supportedTags,
  bool checkTokens = true,
  bool checkAST = true,
  bool checkDelta = true,
  bool checkBBCode = true,
}) {
  final ss = supportedTags ?? defaultSupportedTags;
  final input = '$head$content$tail';
  final parserVersion = TestEnv.parserVersion;

  // Tokens stage.
  final lexer = Lexer(input: input)..scanAll();
  final tokens = lexer.tokens;
  if (checkTokens) {
    expect(tokens, equals(expectedTokens), reason: 'tokens not match as expected');
  }

  // AST stage.
  final parser = switch (parserVersion) {
    BBCodeParserVersion.v1 => ParserV1(tokens: lexer.tokens, supportedTags: ss),
    BBCodeParserVersion.v2 => ParserV2(originalString: input, tokens: lexer.tokens, supportedTags: ss),
  }..parse();
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

void checkMultipleTags({
  required String input,
  required List<Token> expectedTokens,
  required List<BBCodeTag> expectedAST,
  required List<Operation> expectedDelta,
  String? expectedBBCodeOutput,
  List<BBCodeTag>? supportedTags,
  bool checkTokens = true,
  bool checkAST = true,
  bool checkDelta = true,
  bool checkBBCode = true,
}) {
  final ss = supportedTags ?? defaultSupportedTags;
  final parserVersion = TestEnv.parserVersion;

  // Tokens stage.
  final lexer = Lexer(input: input)..scanAll();
  final tokens = lexer.tokens;
  if (checkTokens) {
    expect(tokens, equals(expectedTokens), reason: 'tokens not match as expected');
  }

  // AST stage.
  final parser = switch (parserVersion) {
    BBCodeParserVersion.v1 => ParserV1(tokens: lexer.tokens, supportedTags: ss),
    BBCodeParserVersion.v2 => ParserV2(originalString: input, tokens: lexer.tokens, supportedTags: ss),
  }..parse();
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
    expect(convertBBCodeToText(ast), equals(expectedBBCodeOutput ?? input), reason: 'BBCode not match as expected');
  }
}
