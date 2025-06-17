import 'package:dart_bbcode_parser/src/tags/divider.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('hr tag', () {
    test('with valid format', () {
      const tag = 'hr';
      const head = '[$tag]';
      checkSingleTag(
        head: head,
        content: '',
        tail: '',
        expectedTokens: [const TagHead(start: 0, end: head.length, name: tag, attribute: null)],
        expectedAST: [const DividerTag(start: 0, end: head.length)],
        expectedDelta: [
          Operation.insert({DividerTag.empty.quillEmbedName: DividerTag.empty.quillEmbedValue}, {}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with invalid attribute', () {
      const tag = 'hr';
      const attr = 'attr';
      const head = '[$tag=$attr]';
      checkSingleTag(
        head: head,
        content: '',
        tail: '',
        expectedTokens: [const TagHead(start: 0, end: head.length, name: tag, attribute: attr)],
        expectedAST: [const TextContent(start: 0, end: head.length, data: head)],
        expectedDelta: [Operation.insert(head, {}), Operation.insert('\n')],
      );
    });

    test('with invalid empty attribute', () {
      const tag = 'hr';
      const head = '[$tag=]';
      checkSingleTag(
        head: head,
        content: '',
        tail: '',
        expectedTokens: [const TagHead(start: 0, end: head.length, name: tag, attribute: '')],
        expectedAST: [const TextContent(start: 0, end: head.length, data: head)],
        expectedDelta: [Operation.insert(head, {}), Operation.insert('\n')],
      );
    });
  });
}
