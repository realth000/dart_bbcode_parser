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

  /// Parse and return the generated bbcode tag.
  void parse() {
    // Recognized tag.
    // b color url /url /color /b
    //
    // b color url </url> </color> b [/color]
    final context = _ParseContext();
    for (final token in _tokens) {
      if (token is Text) {
        context.saveText(TextContent(token.data));
      } else if (token is TagHead) {
        if (_isSupported(token.name)) {
          context
            ..enterScope(token)
            ..composeTags();
        } else {
          // Unrecognized tag.
          context.saveText(TextContent('[${token.name}]'));
        }
      } else if (token is TagTail) {
        if (_isSupported(token.name) && context.inScope(token)) {
          // Safely leave the scope and produce a parsed BBCode tag according to supported tags.
          final tagHead = context.leaveScope(token);
          final children = context.popParsed();
          final tag = _buildTag(tagHead, token, children);
          context.saveTag(tag);
        } else {
          // Unrecognized tag or crossed tag, fallback to text.
          context.saveText(TextContent('[/${token.name}]'));
        }
      }
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
    if (head.name != tail.name) {
      throw Exception('can not build tag from head(${head.name}) and tail(${tail.name})');
    }

    final target = _tags.firstWhere((e) => e.name == head.name);
    return target.fromToken(head, tail, children);
  }

  @override
  String toString() => '''
Parser {
  tags {
${_tags.map((e) => "    $e").join('\n')}
  },
  ast {
${_ast.map((e) => "    $e").join('\n')}
  },
}
''';
}

final class _ParseContext {
  _ParseContext();
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
  List<BBCodeTag> parsedTags = [];

  /// Final result.
  List<BBCodeTag> ast = [];

  void enterScope(TagHead head) {
    _scope.add(head);
  }

  TagHead leaveScope(TagTail tail) {
    final s = _scope.lastOrNull;
    if (s != null && s.name == tail.name) {
      return _scope.removeLast();
    }
    throw Exception('calling leaveScope outside of scope $tail');
  }

  List<BBCodeTag> popParsed() {
    final popped = List<BBCodeTag>.from(parsedTags);
    parsedTags.clear();
    return popped;
  }

  /// Is the last memorized scope is [tag].
  bool inScope(TagTail tag)  => _scope.lastOrNull?.name == tag.name ?? false;

  /// Save the [text].
  void saveText(TextContent text)  {
    // if (token is! Text) {
    //   throw Exception('calling saveText on non text token type $token');
    // }
    parsedTags.add(text);
  }

  /// Save a named tag.
  void saveTag(BBCodeTag tag) {
    // if (head is! TagHead || tail is! TagTail || head.name != tail.name) {
    //   throw Exception('calling saveTag on incorrect head $head and tail $tail');
    // }
    ast.add(tag);
  }

  void composeTags() {
    ast.addAll(parsedTags);
    parsedTags.clear();
  }
}

/// Private extension methods on token.
extension _TokenExt on Token {
  /// Is text token.
  bool get isText => tokenType == TokenType.text;

  /// Is head token.
  bool get isHead => tokenType == TokenType.tagHead;

  /// Is tail token.
  bool get isTail => tokenType == TokenType.tagTail;
}