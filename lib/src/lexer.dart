import 'package:dart_bbcode_parser/src/extensions/int.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:string_scanner/string_scanner.dart';

/// Lexer takes a string as input and return a series of tokens.
final class Lexer {
  /// Constructor.
  Lexer({required this.input}) : _scanner = StringScanner(input), _tokens = [];

  /// Original input string.
  final String input;

  final List<Token> _tokens;

  /// The start position of current tag.
  ///
  /// Use this tag to fallback flatten to plain text.
  int currTagStartPos = -1;

  final StringScanner _scanner;

  /// Get scanned tokens.
  List<Token> get tokens => _tokens;

  /// Print all bbcode tokens.
  String toBBCode() {
    final buffer = StringBuffer();
    for (final token in _tokens) {
      buffer.write(token.toBBCode());
    }

    return buffer.toString();
  }

  /// Scan the input string.
  void scanAll() {
    while (!_scanner.isDone) {
      _scanText();
    }
  }

  /// Each run parses a [Text] token.
  ///
  /// Note that it's not guaranteed to consume the most plain text, maybe two or more [Text] token are siblings.
  void _scanText() {
    // Buffer hold the result.
    final buffer = StringBuffer();

    while (true) {
      if (_scanner.isDone) {
        _appendText(buffer);
        currTagStartPos = _scanner.position;
        return;
      }

      final next = _scanner.readChar();
      if (next.isOpen) {
        // Try scan head.
        // Finish the scan process no matter is valid head or not.
        // Chances are that two or more `Text`s are siblings stay beside each other.
        _appendText(buffer);
        currTagStartPos = _scanner.position - 1;
        if (_scanner.peekChar().isSlash) {
          // Read and drop the slash.
          _scanner.readChar();
          // Perhaps tag tail.
          _scanTail();
        } else {
          // Perhaps tag head.
          _scanHead();
        }
        currTagStartPos = _scanner.position;
        return;
      }
      buffer.writeCharCode(next);
    }
  }

  /// Try scan and parse the header of tag.
  ///
  /// Header is `[$NAME=$ATTR]` with attribute or `[$NAME]` without attribute.
  ///
  /// Return true if is valid head, or false if fallbacks to plain text.
  bool _scanHead() {
    final nameBuffer = StringBuffer();
    while (true) {
      if (_scanner.isDone) {
        // Here indicating a incomplete tag head, fallback to plain text.
        _appendText(nameBuffer);
        currTagStartPos = _scanner.position;
        return false;
      }

      final next = _scanner.readChar();
      if (next.isEqual) {
        // Header with attribute.
        // Parse the attribute.
        final attrBuffer = StringBuffer();
        while (true) {
          if (_scanner.isDone) {
            // Empty attribute string.
            break;
          }

          final next2 = _scanner.readChar();
          if (next2.isClose) {
            // Reach the end of attribute.
            // Here we can return the head scan process.
            _appendHead(nameBuffer, attrBuffer);
            currTagStartPos = _scanner.position;
            return true;
          }

          attrBuffer.writeCharCode(next2);
        }
      } else if (next.isClose) {
        _appendHead(nameBuffer, null);
        currTagStartPos = _scanner.position;
        return true;
      } else if (next.isOpen) {
        // Invalid tag head, fallback to plain text.
        _appendConsumedText('[');
        return false;
      }

      nameBuffer.writeCharCode(next);
    }
  }

  /// Try scan and parse the tail of tag.
  bool _scanTail() {
    final nameBuffer = StringBuffer();
    while (true) {
      if (_scanner.isDone) {
        _appendText(nameBuffer);
        currTagStartPos = _scanner.position;
        return false;
      }

      final next = _scanner.readChar();
      if (next.isClose) {
        _appendTail(nameBuffer);
        currTagStartPos = _scanner.position;
        return true;
      }
      nameBuffer.writeCharCode(next);
    }
  }

  /// Build a [Text] token from [buffer] and append it to [_tokens].
  void _appendText(StringBuffer buffer) {
    if (buffer.isEmpty) {
      return;
    }
    _tokens.add(Text(start: currTagStartPos, end: _scanner.position, data: buffer.toString()));
  }

  void _appendConsumedText(String text) {
    if (text.isEmpty) {
      return;
    }
    _tokens.add(Text(start: currTagStartPos, end: _scanner.position, data: text));
  }

  void _appendHead(StringBuffer nameBuffer, StringBuffer? attrBuffer) {
    if (nameBuffer.isEmpty) {
      return;
    }

    _tokens.add(
      TagHead(
        name: nameBuffer.toString(),
        attribute: (attrBuffer == null || attrBuffer.isEmpty) ? null : attrBuffer.toString(),
        start: currTagStartPos,
        end: _scanner.position,
      ),
    );
  }

  void _appendTail(StringBuffer nameBuffer) {
    if (nameBuffer.isEmpty) {
      return;
    }

    _tokens.add(TagTail(name: nameBuffer.toString(), start: currTagStartPos, end: _scanner.position));
  }

  @override
  String toString() => '''
Lexer {
${_tokens.map((e) => '  $e').join('\n')}
}
''';
}

/// State of lexer currently in.
enum _LexerState {
  /// Head tag.
  head,

  /// Tail tag.
  tail,

  /// Collecting plain text.
  text,
}
