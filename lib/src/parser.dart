import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// The parser for bbcode text.
final class Parser {
  /// Constructor.
  Parser({required List<Token> tokens, required List<BBCodeTag> supportedTags})
    : _tokens = tokens,
      _tags = supportedTags,
      _ast = [];

  final List<Token> _tokens;

  /// All supported tags.
  final List<BBCodeTag> _tags;

  /// Parse result.
  List<BBCodeTag> _ast;

  /// Get the parsed result.
  List<BBCodeTag> get ast => _ast;

  /// Parse and return the generated bbcode tag.
  void parse() {
    // Recognized tag.
    // b color url /url /color /b
    //
    // b color url </url> </color> b [/color]
    final context = ParseContext();
    for (final token in _tokens) {
      if (token is Text) {
        context.saveText(TextContent(start: token.start, end: token.end, data: token.data));
      } else if (token is TagHead) {
        if (_isSupported(token.name)) {
          // Try check for self closed tags.
          final tag = _tags.firstWhereOrNull(
            (e) => e.name == token.name && e.selfClosed == true && !e.selfClosedAtTail,
          );
          if (tag != null) {
            // Save self closed tag.
            if (tag.attributeValidator != null && !tag.attributeValidator!.call(token.attribute)) {
              // Tag has invalid attribute.
              context.saveText(
                TextContent(
                  start: token.start,
                  end: token.end,
                  data: '[${token.name}${token.attribute != null ? "=${token.attribute}" : ""}]',
                ),
              );
              continue;
            }

            // Valid self closed tag.
            context.saveTag(tag.fromToken(token, null, []));
            continue;
          }

          context
            ..enterScope(token)
            ..composeTags();
        } else {
          // Unrecognized tag.
          context.saveText(
            TextContent(
              start: token.start,
              end: token.end,
              data: '[${token.name}${token.attribute != null ? "=${token.attribute}" : ""}]',
            ),
          );
        }
      } else if (token is TagTail) {
        if (_isSupported(token.name)) {
          // Try check for self closed tags.
          final tag = _tags.firstWhereOrNull((e) => e.name == token.name && e.selfClosed == true && e.selfClosedAtTail);
          if (tag != null) {
            // Save self closed tag.
            context.saveTag(tag.fromToken(null, token, []));
            continue;
          }

          if (!context.inScope(token)) {
            // Tail token not self closing nor in scope, fallback to text.
            context.saveText(TextContent(start: token.start, end: token.end, data: '[/${token.name}]'));
            continue;
          }

          // Safely leave the scope and produce a parsed BBCode tag according to supported tags.
          final tagHead = context.leaveScope(token);
          final children = context.popParsed(tagHead.start);
          final builtTag = _buildTag(tagHead, token, children);

          if (
          // Validate attribute, if any.
          (builtTag.attributeValidator != null && !builtTag.attributeValidator!.call(tagHead.attribute)) ||
              // Validate children, if any.
              (builtTag.childrenValidator != null && !builtTag.childrenValidator!.call(children))) {
            // Fallback current tag to common tags.
            context.saveText(
              TextContent(
                start: tagHead.start,
                end: tagHead.end,
                data: '[${tagHead.name}${tagHead.attribute != null ? "=${tagHead.attribute}" : ""}]',
              ),
            );
            for (final child in children) {
              context.saveTag(child);
            }
            context.saveText(TextContent(start: token.start, end: token.end, data: '[/${token.name}]'));
            continue;
          }

          // Valid tag.
          context.saveTag(builtTag, rotate: true);
        } else {
          // Unrecognized tag or crossed tag, fallback to text.
          context.saveText(TextContent(start: token.start, end: token.end, data: '[/${token.name}]'));
        }
      }
    }

    // Here we walked through all tokens.
    // All scopes we still live in are invalid ones and shall fallback to text.
    // Consider "[b]foo" and "foo[b]", when we recognize that the "[b]" shall fallback to text, we already walked
    // behind the "foo" text, so when fallback it into state, insert instead of append.
    for (final scope in context._scope) {
      context.insertTextAtPosition(
        TextContent(
          start: scope.start,
          end: scope.end,
          data: '[${scope.name}${scope.attribute != null ? "=${scope.attribute}" : ""}]',
        ),
        scope.start,
      );
    }

    context.composeTags();
    _ast = context.ast;
  }

  bool _isSupported(String name) {
    return _tags.firstWhereOrNull((e) => e.name == name) != null;
  }

  /// Construct the tag from [head] and [tail].
  ///
  /// The caller must ensure [head] and [tail] have the same name.
  BBCodeTag _buildTag(TagHead head, TagTail tail, List<BBCodeTag> children) {
    // Skip name check because the caller has guarantee on it.
    //if (head.name != tail.name) {
    //  throw UnsupportedError('can not build tag from head(${head.name}) and tail(${tail.name})');
    //}

    final target = _tags.firstWhere((e) => e.name == head.name);
    return target.fromToken(head, tail, children);
  }

  @override
  String toString() =>
      '{"stage": "parser", "tokens": ${_tokens.map((e) => e.toJson()).toList()}, "ast":${_ast.map((e) => jsonEncode(e.toJson())).toList()}}';
}

/// Context hold parsed data in parsing process.
final class ParseContext {
  /// Constructor.
  ParseContext();

  /// All scopes.
  ///
  /// A scope is an area between the head of tag and tail of same tag:
  ///
  /// ```console
  /// HeadA  HeadB  text1  TailB  text2  TailA
  /// |------- scope of TagA -----------|
  ///        |- scope of TagB -|
  /// ```
  ///
  /// Tag will only be parsed successfully when Both it's head and tail are confirmed.
  ///
  ///
  /// ## Crossed tags.
  ///
  /// Ideally, for cross applied tags:
  ///
  /// ```console
  /// HeadA  text1  HeadB  text2  TailA text3 TailB
  /// |--------- scope TagA ----------|
  ///               |--------- scope TagB --------|
  /// ```
  ///
  /// After parsing, it becomes:
  ///
  /// ```console
  /// HeadA  text1  HeadB  text2  TailA text3 TailB
  /// |--- scope TagA ---|
  ///               |--- scope TagB ---|
  ///                             |--- scope TagA ---|
  /// ```
  ///
  /// where:
  ///
  /// * `text1` has attribute `TagA`.
  /// * `text2` has both attribute `TagA` and attribute `TagB`.
  /// * `text3` has attribute `TagB`.
  ///
  /// This is some server side behavior processed by `bbcode2html`, but it shall not be encouraged to this stuff, nether
  /// the quill delta format. In a far away future we may implement it, but now we consider it as **INVALID**.
  final List<TagHead> _scope = [];

  /// Save successfully parsed tags.
  ///
  /// A temporary list of tags that recognized but not composed together.
  // List<BBCodeTag> parsedTags = [];

  /// Final result.
  List<BBCodeTag> ast = [];

  /// Record new tag scope.
  void enterScope(TagHead head) {
    _scope.add(head);
  }

  /// Remove recorded tag scope.
  ///
  /// The scope shall be the last one in [_scope], act like stack.
  TagHead leaveScope(TagTail tail) {
    final s = _scope.lastOrNull;
    if (s != null && s.name == tail.name) {
      return _scope.removeLast();
    }
    throw UnsupportedError('calling leaveScope outside of scope $tail');
  }

  /// Pop all parsed tags not before the position [after].
  List<BBCodeTag> popParsed(int after) {
    final popped = List<BBCodeTag>.from(ast.skipWhile((e) => e.start <= after));
    if (popped.isNotEmpty && ast.isNotEmpty) {
      ast.removeRange(ast.length - popped.length, ast.length);
    }
    return popped;
  }

  /// Is the last memorized scope is [tag].
  bool inScope(TagTail tag) => _scope.lastOrNull?.name == tag.name;

  /// Save the [text].
  void saveText(TextContent text) {
    ast.add(text);
  }

  /// Save the [text] at the position start at [start].
  ///
  /// Unlike [saveText] always append [text] to the tail of [ast], this function may insert between tags.
  ///
  /// ```console
  /// TAG1 TAG2
  /// |    |
  /// 10   15
  ///    |
  ///    13, where the text may insert.
  /// ```
  void insertTextAtPosition(TextContent text, int start) {
    for (final (idx, node) in ast.indexed) {
      if (node.start < start) {
        continue;
      }

      ast.insert(math.max(0, idx - 1), text);
      return;
    }

    // All tags in ast are before [text].
    ast.add(text);
  }

  /// Save a named tag.
  ///
  /// Add [tag] to the ast and a more important thing: transform the AST by checking previously saved children tags.
  ///
  /// Detailed explanation:
  ///
  /// Our parsing process is linear, which means it will save the recognized tag immediately, without checking for
  /// parent nodes:
  ///
  /// ```console
  /// [b] [i] text [/i] [/b]
  /// ```
  ///
  /// For the example above, when the parsing process at `[/b]`, it save the valid tag `[b]` to AST, but it does not
  /// know `[i]` and `text` are its children, so an extra step is needed here, checking tags already in the AST, if
  /// these previous tags have a start pos after the current pending one, it means these tags are inside current tag,
  /// move them to be current tags' children.
  void saveTag(BBCodeTag tag, {bool rotate = false}) {
    // Rotating AST steps are skipped.
    //
    // Theoretically here are cases we need to rotate the AST because we only walk through the tree once:
    //
    // Consider the following BBCode: `before[b][i][/i][b]`, when processing on the tag tail `[/b]`, the `i` tag has
    // been built and saved to AST, but exactly it is the children of `b`, when processing here we MUST remove the `i`
    // from AST and built `b` first, then move the `i` as `b`'s child, this process is rotating.
    // But we can not cover this case in test, somewhere else MUST have done this step, we do not notice it.
    //
    // Seems we do not need rotating, disable it.
    //
    // To enable it again, uncomment the code below and set `rotate` parameter to `true` when call this function.
    //
    // int? removeRangeStartIndex;
    // if (!tag.isPlainText && ast.isNotEmpty && rotate && !tag.selfClosed) {
    //   final childrenTags = <BBCodeTag>[];
    //   for (var i = ast.length - 1; i >= 0; i--) {
    //     if (ast[i].start <= tag.start) {
    //       break;
    //     }
    //     removeRangeStartIndex = i;
    //     childrenTags.add(ast[i]);
    //   }
    //   tag.children.addAll(childrenTags.reversed.toList());
    // }
    // if (removeRangeStartIndex != null) {
    //   ast.removeRange(removeRangeStartIndex, ast.length);
    // }

    ast.add(tag);
  }

  /// Compose adjacent texts.
  void composeTags() {
    // ast.addAll(parsedTags);
    // parsedTags.clear();
  }
}
