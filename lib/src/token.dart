/// Type of token.
enum TokenType {
  /// Plain text.
  text,

  /// Head of tag.
  tagHead,

  /// End of tag.
  tagTail,
}

/// Basic token definition.
abstract interface class Token {
  /// Get the token type.
  TokenType get tokenType;

  /// Convert to bbcode text.
  String toBBCode();

  /// Get the token position in original string.
  ({int start, int end}) get position;

  /// Get the length of token.
  int get length;
}

/// Plain text token.
class Text implements Token {
  /// Constructor.
  const Text({required this.data, required this.start, required this.end});

  /// The data here.
  final String data;

  /// Start position.
  final int start;

  /// End position.
  ///
  /// The first position after the last character in [data].
  final int end;

  @override
  int get length => data.length;

  @override
  ({int end, int start}) get position => (start: start, end: end);

  @override
  String toBBCode() => data;

  @override
  TokenType get tokenType => TokenType.text;

  @override
  String toString() => 'Text { start=$start; end=$end; data=$data; }';
}

/// Head of tag.
///
/// In `[$NAME=$ATTR]` format.
class TagHead implements Token {
  /// Constructor.
  const TagHead({required this.name, required this.attribute, required this.start, required this.end});

  /// Tag name.
  final String name;

  /// Optional attribute.
  final String? attribute;

  /// Start of head.
  ///
  /// Position of '['.
  final int start;

  /// End of head.
  ///
  /// Position of ']'.
  final int end;

  @override
  int get length => end - start;

  @override
  ({int end, int start}) get position => (start: start, end: end);

  @override
  String toBBCode() => '[$name${attribute == null ? "" : "=$attribute"}]';

  @override
  TokenType get tokenType => TokenType.tagHead;

  @override
  String toString() =>
      'TagHead { start=$start; end=$end; name="$name";${attribute == null ? "" : ' attribute="$attribute"'} }';
}

/// The tail of tag.
class TagTail implements Token {
  /// Constructor.
  const TagTail({required this.name, required this.start, required this.end});

  /// Tag name.
  final String name;

  /// Start of head.
  ///
  /// Position of '['.
  final int start;

  /// End of head.
  ///
  /// Position of ']'.
  final int end;

  @override
  int get length => end - start;

  @override
  // TODO: implement position
  ({int end, int start}) get position => (start: start, end: end);

  @override
  String toBBCode() => '[/$name]';

  @override
  TokenType get tokenType => TokenType.tagTail;

  @override
  String toString() => 'TagTail { start=$start; end=$end; name=$name; }';
}
