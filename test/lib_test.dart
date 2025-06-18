import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

void main() {
  group('parse bbcode tag to text', () {
    test('from plain text', () {
      final tags = parseBBCodeTextToTags('text');
      expect(tags.length, equals(1));
      expect(tags.first, equals(const TextContent(start: 0, end: 4, data: 'text')));
    });

    test('from simple tag', () {
      final tags = parseBBCodeTextToTags('[b]bold_text[/b][i][/i]');
      expect(tags.length, equals(2));
      expect(
        tags.first,
        equals(const BoldTag(start: 0, end: 16, children: [TextContent(start: 3, end: 12, data: 'bold_text')])),
      );
      expect(tags.last, equals(const ItalicTag(start: 17, end: 24, children: [])));
    });

    test('with unknown tag', () {
      final tags = parseBBCodeTextToTags('[unknown]test[/unknown]');
      expect(tags.length, equals(3));
      expect(tags[0], equals(const TextContent(start: 0, end: 9, data: '[unknown]')));
      expect(tags[1], equals(const TextContent(start: 9, end: 13, data: 'test')));
      expect(tags[2], equals(const TextContent(start: 13, end: 23, data: '[/unknown]')));
    });
  });

  group('parse bbcode to delta', () {
    test('from plain text', () {
      final delta = parseBBCodeTextToDelta('text');
      final op = delta.operations;
      expect(op.length, 2);
      expect(op[0].toJson(), equals(Operation.insert('text', {}).toJson()));
      expect(op[1].toJson(), equals(Operation.insert('\n').toJson()));
    });

    test('from simple tag', () {
      final delta = parseBBCodeTextToDelta('[b]bold_text[/b][i][/i]');
      final op = delta.operations;
      expect(op.length, 3);
      expect(op[0].toJson(), equals(Operation.insert('bold_text', {'bold': true}).toJson()));
      expect(op[1].toJson(), equals(Operation.insert('', {'italic': true}).toJson()));
      expect(op[2].toJson(), equals(Operation.insert('\n').toJson()));
    });

    test('with unknown tag', () {
      const input = '[unknown]test[/unknown]';
      final op = parseBBCodeTextToDelta(input);
      expect(op.length, equals(4));
      expect(op[0].toJson(), equals(Operation.insert('[unknown]', {}).toJson()));
      expect(op[1].toJson(), equals(Operation.insert('test', {}).toJson()));
      expect(op[2].toJson(), equals(Operation.insert('[/unknown]', {}).toJson()));
      expect(op[3].toJson(), equals(Operation.insert('\n').toJson()));
    });
  });
}
