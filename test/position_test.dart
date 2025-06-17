import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('text position', () {
    test('plain text', () {
      const content = 'CONTENT';
      checkSingleTag(
        head: '',
        content: content,
        tail: '',
        expectedTokens: [const Text(start: 0, end: content.length, data: content)],
        expectedAST: [const TextContent(start: 0, end: content.length, data: content)],
        expectedDelta: [Operation.insert(content, {}), Operation.insert('\n')],
      );
    });
  });
}
