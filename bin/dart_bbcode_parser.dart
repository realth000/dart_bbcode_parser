// Cli printing messages.
// ignore_for_file: avoid_print
import 'package:dart_bbcode_parser/src/lexer.dart';

int main(List<String> args) {
  if (args.isEmpty) {
    print('usage: bbcode_parser <bbcode>');
    return 0;
  }

  final lexer = Lexer(input: args.first)..scanAll();
  print(lexer);

  return 0;
}
