import 'package:dart_bbcode_parser/src/lexer.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/quill/delta.dart';
import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/backgroud_color.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/code.dart';
import 'package:dart_bbcode_parser/src/tags/color.dart';
import 'package:dart_bbcode_parser/src/tags/divider.dart';
import 'package:dart_bbcode_parser/src/tags/font_size.dart';
import 'package:dart_bbcode_parser/src/tags/free_v2.dart';
import 'package:dart_bbcode_parser/src/tags/hide_v2.dart';
import 'package:dart_bbcode_parser/src/tags/image.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/quote.dart';
import 'package:dart_bbcode_parser/src/tags/spoiler_v2.dart';
import 'package:dart_bbcode_parser/src/tags/strikethrough.dart';
import 'package:dart_bbcode_parser/src/tags/superscript.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/tags/underline.dart';
import 'package:dart_bbcode_parser/src/tags/url.dart';
import 'package:dart_bbcode_parser/src/tags/user_mention.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// BBCode tags that are enabled by default.
const defaultSupportedTags = [
  AlignTag.empty,
  BackgroundColorTag.empty,
  BoldTag.empty,
  CodeTag.empty,
  ColorTag.empty,
  DividerTag.empty,
  FontSizeTag.empty,
  FreeV2HeaderTag.empty,
  FreeV2TailTag.empty,
  HideV2HeaderTag.empty,
  HideV2TailTag.empty,
  ImageTag.empty,
  ItalicTag.empty,
  QuoteTag.empty,
  StrikethroughTag.empty,
  SuperscriptTag.empty,
  SpoilerV2HeaderTag.empty,
  SpoilerV2TailTag.empty,
  UnderlineTag.empty,
  UrlTag.empty,
  UserMentionTag.empty,
];

/// Parse a list of tags, or call it AST, to plain bbcode text.
String convertBBCodeToText(List<BBCodeTag> tags) {
  final buffer = StringBuffer();
  for (final tag in tags) {
    tag.toBBCode(buffer);
  }
  return buffer.toString();
}

/// Parse plain [bbcode] to String.
List<BBCodeTag> parseBBCodeTextToTags(String bbcode) {
  final lexer = Lexer(input: bbcode)..scanAll();
  final parser = Parser(tokens: lexer.tokens, supportedTags: defaultSupportedTags)..parse();
  return parser.ast;
}

/// Parse plain [bbcode] text into quill [Delta].
Delta parseBBCodeTextToDelta(String bbcode) {
  final lexer = Lexer(input: bbcode)..scanAll();
  final parser = Parser(tokens: lexer.tokens, supportedTags: defaultSupportedTags)..parse();
  final ast = parser.ast;
  final delta = buildDelta(ast);
  return delta;
}
