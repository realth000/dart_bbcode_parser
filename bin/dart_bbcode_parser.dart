// Cli printing messages.
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';

const flagLexOnly = 'lex';
const flagParseOnly = 'parse';

Future<int> main(List<String> args) async {
  if (args.isEmpty) {
    print('usage: bbcode_parser <bbcode>');
    return 0;
  }

  final argParser =
      ArgParser()
        ..addOption('code', abbr: 'c', help: 'parse bbcode from stdin', valueHelp: 'bbcode')
        ..addOption('file', abbr: 'f', help: 'read and parse bbcode from file', valueHelp: 'file_path')
        ..addFlag(flagLexOnly, abbr: 'l', help: 'process till lex end and print lexed result (tokens)')
        ..addFlag(flagParseOnly, abbr: 'p', help: 'process till parse end and print parsed result (bbcode)');

  final parsedArgs = argParser.parse(args);

  if (parsedArgs.option('code') != null) {
    final delta = parseBBCodeTextToDelta(parsedArgs.option('code')!);
    print('$delta');
    return 0;
  }

  if (parsedArgs.option('file') != null) {
    final content = await File(parsedArgs.option('file')!).readAsString();
    final lexer = Lexer(input: content)..scanAll();
    if (parsedArgs.flag(flagLexOnly)) {
      print(lexer.tokens);
      return 0;
    }
    final parser = Parser(tokens: lexer.tokens, supportedTags: defaultSupportedTags)..parse();
    if (parsedArgs.flag(flagParseOnly)) {
      print(parser.ast);
      return 0;
    }
    final delta = buildDelta(parser.ast);
    print('$delta');
    return 0;
  }

  print(argParser.usage);
  return 1;
}
