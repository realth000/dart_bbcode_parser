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
  int currTagStartPos = 0;

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
        _appendText(buffer, true);
        currTagStartPos = _scanner.position - 1;
        final next2 = _scanner.peekChar();
        if (next2.isSlash) {
          // Read and drop the slash.
          _scanner.readChar();
          // Perhaps tag tail.
          _scanTail();
        } else if (next2.isOpen) {
          // '[[', fallback to text.
          _appendConsumedText('[');
          _scanText();
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
  /// When enter this function, position MUST be after the `[`.
  ///
  /// Return true if is valid head, or false if fallbacks to plain text.
  bool _scanHead() {
    final nameBuffer = StringBuffer();
    while (true) {
      if (_scanner.isDone) {
        // Here indicating a incomplete tag head and reaches the end of input, fallback to plain text.
        // Don't forget to save the consumed '[' when we enter this function.
        // Use the fixed end parameter because we know the '[' where starts and length is fixed to 1.
        _appendConsumedText('[', end: currTagStartPos + 1);
        currTagStartPos = currTagStartPos + 1;
        _appendText(nameBuffer);
        return false;
      }

      final next = _scanner.readChar();
      if (next.isEqual) {
        if (nameBuffer.isEmpty) {
          // Currently we have "[=", position is at the "=".
          // It should be considered as plain text.
          _appendConsumedText('[=');
          return false;
        }

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
        if (nameBuffer.isEmpty) {
          // Currently we have "[]", position is at the "]".
          // It should be considered as plain text.
          _appendConsumedText('[]');
          return false;
        }

        _appendHead(nameBuffer, null);
        currTagStartPos = _scanner.position;
        return true;
      }

      nameBuffer.writeCharCode(next);
    }
  }

  /// Try scan and parse the tail of tag `[/$NAME]`.
  ///
  /// When enter this function, position MUST be after the `[/`.
  bool _scanTail() {
    final nameBuffer = StringBuffer();
    while (true) {
      if (_scanner.isDone) {
        // Here we reaches the end of input with incomplete tag tail.
        // Don't forget the eaten prefix '[/'.
        _appendConsumedText('[/', end: currTagStartPos + 2);
        currTagStartPos = currTagStartPos + 2;
        _appendText(nameBuffer);
        return false;
      }

      final next = _scanner.readChar();
      if (next.isClose) {
        if (nameBuffer.isEmpty) {
          // Here we reaches the end of input with incomplete tag tail.
          // Don't forget the eaten prefix '[/'.
          _appendConsumedText('[/]', end: currTagStartPos + 3);
          currTagStartPos = currTagStartPos + 3;
        }
        _appendTail(nameBuffer);
        currTagStartPos = _scanner.position;
        return true;
      }
      nameBuffer.writeCharCode(next);
    }
  }

  /// Build a [Text] token from [buffer] and append it to [_tokens].
  void _appendText(StringBuffer buffer, [bool overRead = false]) {
    if (buffer.isEmpty) {
      return;
    }
    final int end;
    if (overRead) {
      end = _scanner.position - 1;
    } else {
      end = _scanner.position;
    }

    _tokens.add(Text(start: currTagStartPos, end: end, data: buffer.toString()));
  }

  void _appendConsumedText(String text, {int? end}) {
    if (text.isEmpty) {
      return;
    }
    _tokens.add(Text(start: currTagStartPos, end: end ?? _scanner.position, data: text));
  }

  void _appendHead(StringBuffer nameBuffer, StringBuffer? attrBuffer) {
    if (nameBuffer.isEmpty) {
      return;
    }

    _tokens.add(
      TagHead(
        name: nameBuffer.toString(),
        attribute: attrBuffer?.toString(),
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
  String toString() => '{"stage":"lexer","tokens":${_tokens.map((e) => e.toJson()).toList()}}';
}
