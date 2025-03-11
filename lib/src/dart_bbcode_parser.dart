import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/url.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Parse plain [bbcode] text into quill [Delta].
Delta parseBBCodeTextToDelta(String bbcode) {
  final lexer = Lexer(input: bbcode)..scanAll();
  final parser = Parser(tokens: lexer.tokens, supportedTags: [const BoldTag(), const ItalicTag(), const UrlTag()])
    ..parse();
  final ast = parser.ast;
  final delta = buildDelta(ast);
  return delta;
}
