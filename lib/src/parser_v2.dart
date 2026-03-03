import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dart_bbcode_parser/src/parser.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// The parser for bbcode text, version 2.
final class ParserV2 implements Parser {
  /// Constructor.
  ParserV2({required String originalString, required List<Token> tokens, required List<BBCodeTag> supportedTags})
    : _originalString = originalString,
      _tokens = tokens,
      _tags = supportedTags,
      _topTags = List.empty(growable: true),
      _currentPathTags = List.empty(growable: true);

  /// The original input raw text.
  ///
  /// Use this field to fetch original text contents in specific ranges.
  final String _originalString;

  /// All input tokens to parse.
  final List<Token> _tokens;

  /// All supported tag types.
  final List<BBCodeTag> _tags;

  /// Current tag paths.
  ///
  /// Each tag in this list is a node in current "tag path":
  /// The more tags here, the deep tag path is.
  final List<BBCodeTag> _currentPathTags;

  /// All top-level tags in the AST.
  final List<BBCodeTag> _topTags;

  /// A flag indicating is next '\n' should be ignored. (From V1)
  bool _ignoreNextLineFeed = false;

  /// Get the parsed result.
  @override
  List<BBCodeTag> get ast => _topTags;

  /// Parse all input tokens.
  @override
  void parse() {
    for (final token in _tokens) {
      if (token is TagHead) {
        // Check for supported and self closed tags.
        final tagType = _tags.firstWhereOrNull((e) => e.name == token.name && !e.selfClosedAtTail);
        if (!_isSupported(token.name) || tagType == null) {
          // Invalid tag type, fallback to text and save.
          _saveText(_buildOriginalTokenText(token));
          continue;
        }

        // Validate attribute and parent.
        if ((tagType.attributeValidator != null && !tagType.attributeValidator!.call(token.attribute)) ||
            (tagType.parentValidator != null && !tagType.parentValidator!.call(_currentPathTags.lastOrNull))) {
          // Tag attribute invalid, fallback to text and save.
          _saveText(_buildOriginalTokenText(token));
          continue;
        }

        if (tagType.target == ApplyTarget.paragraph) {
          // Logic from V1: Manage paragraph-level line feed.
          _ignoreNextLineFeed = true;
        }

        // Logic from V1: Support self-closed tags that trigger at Head.
        if (tagType.selfClosed && !tagType.selfClosedAtTail) {
          final tag = tagType.fromToken(token, null, []);
          _saveTagHead(tag, canHaveChildren: false);
          continue;
        }

        final tag = tagType.fromToken(token, null, []);
        _saveTagHead(tag);
        continue;
      }

      if (token is TagTail) {
        // Logic from V1: Support self-closed tags that trigger at Tail.
        final tagType = _tags.firstWhereOrNull((e) => e.name == token.name && e.selfClosedAtTail);

        if (tagType != null && tagType.selfClosed && tagType.selfClosedAtTail) {
          _saveTagHead(tagType.fromToken(null, token, []), canHaveChildren: false);
          continue;
        }

        if (_currentPathTags.isNotEmpty && _currentPathTags.last.name == token.name) {
          final currentTag = _currentPathTags.last;

          // Validate children and parent.
          if ((currentTag.childrenValidator != null && !currentTag.childrenValidator!.call(currentTag.children)) ||
              (tagType != null && tagType.parentValidator != null && !tagType.parentValidator!.call(currentTag))) {
            // If invalid, fallback the Head to text and move children up.
            _fallbackTagHead(currentTag);
            _saveText(_buildOriginalTokenText(token));
            continue;
          }

          final rebuiltTag = currentTag.fromToken(
            TagHead(
              name: currentTag.name,
              start: currentTag.start,
              end: currentTag.start,
              attribute: currentTag.attribute,
            ),
            token, // Pass the actual TagTail.
            List.from(currentTag.children),
          )..end = token.end;

          _currentPathTags.removeLast();
          _replaceInParent(currentTag, rebuiltTag);
        } else {
          // No corresponding tag head or crossed tag, fallback to text.
          _saveText(_buildOriginalTokenText(token));
        }
        continue;
      }

      if (token is Text) {
        _handleTextContent(token);
        continue;
      }

      throw Exception('unreachable: unknown type tag: $token');
    }

    // Logic from V1: Unclosed tags should fallback to text with position preservation.
    // By processing from inside to outside, we maintain correct document order.
    while (_currentPathTags.isNotEmpty) {
      _fallbackTagHead(_currentPathTags.last);
    }
  }

  /// Handles text tokens and the special [_ignoreNextLineFeed] logic.
  void _handleTextContent(Text text) {
    var data = text.data;
    var end = text.end;

    if (_ignoreNextLineFeed && data.endsWith('\n')) {
      _ignoreNextLineFeed = false;
      if (data == '\n') {
        return;
      }

      data = data.substring(0, data.length - 1);
      // Do NOT modify `end` here as we are ignore the LF in quill delta, still keep it
      // in bbcode.
      end -= 1;
    }

    _saveText(TextContent(start: text.start, end: end, data: data));
  }

  /// Replaces a [BBCodeTag] in the current tree with its text fallback and flattens its children.
  void _fallbackTagHead(BBCodeTag tag) {
    final idx = _currentPathTags.indexOf(tag);

    _currentPathTags.remove(tag);
    final fallbackText = _buildOriginalTokenText(
      TagHead(name: tag.name, start: tag.start, end: tag.end, attribute: tag.attribute),
    );

    final list = _currentPathTags.isEmpty ? _topTags : _currentPathTags.last.children;
    final index = list.indexOf(tag);
    if (index != -1) {
      list
        ..removeAt(index)
        ..insert(index, fallbackText);
    }

    // After fallback the head, validate children again.
    if (idx != -1) {
      for (final child in tag.children.reversed) {
        if (!child.isPlainText && child.parentValidator != null && !child.parentValidator!.call(fallbackText)) {
          list.insert(
            index + 1,
            TextContent.fromOriginalInput(originalString: _originalString, start: child.start, end: child.end),
          );
        } else {
          list.insert(index + 1, child);
        }
      }
    }
  }

  /// Replaces an existing tag instance with a rebuilt (closed) tag instance.
  void _replaceInParent(BBCodeTag oldTag, BBCodeTag newTag) {
    final list = _currentPathTags.isEmpty ? _topTags : _currentPathTags.last.children;
    final index = list.indexOf(oldTag);
    if (index != -1) {
      list[index] = newTag;
    }
  }

  /// Get the original plain text in original input string for given token.
  TextContent _buildOriginalTokenText(Token token) => TextContent.fromOriginalInput(
    originalString: _originalString,
    start: token.position.start,
    end: token.position.end,
  );

  bool _isSupported(String name) {
    return _tags.firstWhereOrNull((e) => e.name == name) != null;
  }

  void _saveTagHead(BBCodeTag tag, {bool canHaveChildren = true}) {
    if (_currentPathTags.isEmpty) {
      _topTags.add(tag);
    } else {
      _currentPathTags.last.children.add(tag);
    }

    if (canHaveChildren) {
      _currentPathTags.add(tag);
    }
  }

  void _saveText(TextContent textContent) {
    if (_currentPathTags.isEmpty) {
      _topTags.add(textContent);
    } else {
      _currentPathTags.last.children.add(textContent);
    }
  }

  @override
  String toString() =>
      '{"stage": "parser", "tokens": ${_tokens.map((e) => e.toJson()).toList()}, "ast":${_topTags.map((e) => jsonEncode(e.toJson())).toList()}}';
}
