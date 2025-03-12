import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/backgroud_color.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/color.dart';
import 'package:dart_bbcode_parser/src/tags/font_size.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/strikethrough.dart';
import 'package:dart_bbcode_parser/src/tags/superscript.dart';
import 'package:dart_bbcode_parser/src/tags/underline.dart';
import 'package:dart_bbcode_parser/src/tags/url.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// BBCode tags that are enabled by default.
const defaultSupportedTags = [
  BoldTag(),
  ItalicTag(),
  UnderlineTag(),
  StrikethroughTag(),
  UrlTag(),
  FontSizeTag(attribute: ''),
  ColorTag(attribute: ''),
  BackgroundColorTag(attribute: ''),
  SuperscriptTag(),
];

/// Parse plain [bbcode] text into quill [Delta].
Delta parseBBCodeTextToDelta(String bbcode) {
  final lexer = Lexer(input: bbcode)..scanAll();
  final parser = Parser(tokens: lexer.tokens, supportedTags: defaultSupportedTags)..parse();
  final ast = parser.ast;
  final delta = buildDelta(ast);
  return delta;
}
