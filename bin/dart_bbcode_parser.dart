// Cli printing messages.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/url.dart';

Future<int> main(List<String> args) async {
  if (args.isEmpty) {
    print('usage: bbcode_parser <bbcode>');
    return 0;
  }

  final parser =
      ArgParser()
        ..addOption('code', abbr: 'c', help: 'parse bbcode from stdin', valueHelp: 'bbcode')
        ..addOption('file', abbr: 'f', help: 'read and parse bbcode from file', valueHelp: 'file_path');

  final result = parser.parse(args);

  if (result.option('code') != null) {
    final delta = parseBBCodeTextToDelta(result.option('code')!);
    print('$delta');
    return 0;
  }

  if (result.option('file') != null) {
    final content = await File(result.option('file')!).readAsString();
    final delta = parseBBCodeTextToDelta(content);
    print('$delta');
    return 0;
  }

  print(parser.usage);
  return 1;
}
