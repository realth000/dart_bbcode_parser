/// Currently which type of position is in, or expected to be in.
enum _ChunkType {
  /// Munching plain text, not in any tag.
  text,

  /// In open square bracket '['.
  head,

  /// In close square bracket ']'.
  tail,

  /// In the body of some tag.
  body,
}

/// Parsed chunk of bbcode on current position with latest parse history.
final class Chunk {
  /// Constructor.
  Chunk._(this._pos, this._type, this._content);

  /// Parsing text.
  factory Chunk.text(int pos, String ch) =>
      Chunk._(pos, _ChunkType.text, StringBuffer(ch));

  /// Parsing tag head.
  factory Chunk.head(int pos, String ch) =>
      Chunk._(pos, _ChunkType.head, StringBuffer(ch));

  /// Parsing tag tail.
  factory Chunk.tail(int pos, String ch) =>
      Chunk._(pos, _ChunkType.tail, StringBuffer(ch));

  /// Parsing tag body.
  factory Chunk.body(int pos, String ch) =>
      Chunk._(pos, _ChunkType.body, StringBuffer(ch));

  /// Current state.
  final _ChunkType _type;

  /// Character at current position.
  StringBuffer _content;

  /// Start position of munched text in current parsing state.
  int _pos;

  /// Is a text chunk.
  bool get inText => _type == _ChunkType.text;

  /// Is a head chunk.
  bool get inHead => _type == _ChunkType.head;

  /// Is a tail chunk.
  bool get inTail => _type == _ChunkType.tail;

  /// Is a body chunk.
  bool get inBody => _type == _ChunkType.body;

  /// Get the start position of current chunk.
  int get startPos => _pos;

  /// Get the length currently chunked data.
  int get length => _content.length;

  /// Push [data] into current parsed content.
  void push(String data) => _content.write(data);
}
