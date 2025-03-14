// Cli printing messages.
// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/url.dart';

int main(List<String> args) {
  if (args.isEmpty) {
    print('usage: bbcode_parser <bbcode>');
    return 0;
  }

  final lexer = Lexer(input: args.first)..scanAll();
  print(lexer);

  final parser = Parser(tokens: lexer.tokens, supportedTags: [const BoldTag(), const ItalicTag(), const UrlTag()])
    ..parse();
  final ast = parser.ast;
  final delta = buildDelta(ast);
  const jsonEncoder = JsonEncoder.withIndent('  ');
  print(jsonEncoder.convert(delta.toJson()));
  return 0;
}
