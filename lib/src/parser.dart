import 'package:dart_bbcode_parser/src/tags/tag.dart';

/// Parser interface.
abstract interface class Parser {
  /// Do the parsing.
  void parse();

  /// Get the parsed ast.
  List<BBCodeTag> get ast;
}
