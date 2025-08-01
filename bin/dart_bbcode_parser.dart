// Cli printing messages.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/list.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

const flagLexOnly = 'lex';
const flagParseOnly = 'parse';

Future<int> main(List<String> args) async {
  final argParser =
      ArgParser()
        ..addSeparator('Options:')
        ..addOption('code', abbr: 'c', help: 'parse bbcode from stdin', valueHelp: 'bbcode')
        ..addOption('file', abbr: 'f', help: 'read and parse bbcode from file', valueHelp: 'file_path')
        ..addSeparator('Processing flags:')
        ..addFlag(flagLexOnly, abbr: 'l', help: 'process till lex end and print lexed result (tokens)')
        ..addFlag(flagParseOnly, abbr: 'p', help: 'process till parse end and print parsed result (bbcode)')
        ..addSeparator('Other flags:')
        ..addFlag('help', abbr: 'h', help: 'print this help message');

  if (args.isEmpty) {
    print('usage:');
    print('');
    print(argParser.usage);
    return 0;
  }

  const encoder = JsonEncoder.withIndent('  ');

  final parsedArgs = argParser.parse(args);

  if (parsedArgs.flag('help')) {
    print('usage:');
    print('');
    print(argParser.usage);
    return 0;
  }

  if (parsedArgs.option('code') != null) {
    final delta = parseBBCodeTextToDelta(parsedArgs.option('code')!);
    print('$delta');
    return 0;
  }

  if (parsedArgs.option('file') != null) {
    final content = await File(parsedArgs.option('file')!).readAsString();
    final lexer = Lexer(input: content)..scanAll();
    if (parsedArgs.flag(flagLexOnly)) {
      print(encoder.convert(lexer.tokens));
      return 0;
    }

    final parser = Parser(tokens: lexer.tokens, supportedTags: defaultSupportedTags)..parse();
    if (parsedArgs.flag(flagParseOnly)) {
      print(encoder.convert(parser.ast));
      return 0;
    }

    var delta = buildDelta(parser.ast);

    print(encoder.convert(delta));
    // TODO: Only do it if ListTag is enabled.
    delta = Delta.fromOperations(ListItemTag.normalizeListItemQuill(delta.operations));
    print(encoder.convert(delta));
    return 0;
  }

  print(argParser.usage);
  return 1;
}
