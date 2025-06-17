import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('bold tag', () {
    test('without content', () {
      const tag = 'b';
      const head = '[$tag]';
      const content = '';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: null),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [const BoldTag(start: 0, end: head.length + content.length + tail.length)],
        expectedDelta: [
          Operation.insert(content, {BoldTag.empty.quillAttrName: true}),
          Operation.insert('\n'),
        ],
      );
    });

    test('with content', () {
      const tag = 'b';
      const head = '[$tag]';
      const content = 'CONTENT';
      const tail = '[/$tag]';
      checkSingleTag(
        head: head,
        content: content,
        tail: tail,
        expectedTokens: [
          const TagHead(start: 0, end: head.length, name: tag, attribute: null),
          const Text(start: head.length, end: head.length + content.length + 1, data: content),
          const TagTail(
            start: head.length + content.length,
            end: head.length + content.length + tail.length,
            name: tag,
          ),
        ],
        expectedAST: [
          const BoldTag(
            start: 0,
            end: head.length + content.length + tail.length,
            children: [TextContent(start: head.length, end: head.length + content.length + 1, data: content)],
          ),
        ],
        expectedDelta: [
          Operation.insert(content, {BoldTag.empty.quillAttrName: true}),
          Operation.insert('\n'),
        ],
      );
    });
  });
}
