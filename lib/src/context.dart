import 'package:dart_bbcode_parser/src/chunk.dart';

/// Current context when parsing bbcode, carrying all information.
class ParseContext {
  /// Constructor.
  const ParseContext({
    required this.stateHistory,
  });

  /// All state history carrying.
  ///
  /// This should be used as a stack.
  final List<Chunk> stateHistory;
}
