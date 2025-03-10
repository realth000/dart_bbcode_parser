import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';

/// The parser for bbcode text.
final class Parser {
  /// Constructor.
  const Parser({required List<Token> tokens,required List<BBCodeTag> supportedTags}) :_tokens = tokens, _tags = supportedTags;

  final List<Token> _tokens;

  /// All supported tags.
  final List<BBCodeTag> _tags;

  /// Parse and return the generated bbcode tag.
  List<BBCodeTag> parse() {
    final context = _ParseContext();
    for (final token in _tokens) {
      if (token is Text) {
        context.saveText(TextContent(token.data));
        continue;
      }
      if (token is TagHead) {
        context.enterScope(token);
        continue;
      }
      if(token is TagTail) {
        if (context.inScope(token)) {
          // Safely leave the scope and produce a parsed BBCode tag according to supported tags.
          throw UnimplementedError('leave scope and produce tag');
        } else {
          // Out of scope, or tag not supported, fallback to plain text.
          throw UnimplementedError('out of scope, fallback to plain text');
        }
      }
    }
    return context.parsedTags;
  }
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
  final List<TagHead> _scope = const [];

  /// Save successfully parsed tags.
  List<BBCodeTag> parsedTags = const [];

  void enterScope(TagHead head) {
    _scope.add(head);
  }

  void leaveScope(TagTail tail) {
    final s = _scope.lastOrNull;
    if (s != null && s.name == tail.name) {
      _scope.removeLast();
    }
    throw Exception('calling leaveScope outside of scope $tail');
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
    parsedTags.add(tag);
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