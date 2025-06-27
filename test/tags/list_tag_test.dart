import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('list tags', () {
    test('parsing simple bullet tag', () {
      const input = '''
[list]
[*]a
[/list]
      ''';
      final tag = buildSingleTag(input: input);
      expect(tag.toJson(), {
        'start': 0,
        'end': 19,
        'open': '[',
        'close': ']',
        'name': 'list',
        'selfClosed': false,
        'selfClosedAtTail': false,
        'hasQuillAttr': false,
        'quillAttrName': '<unsupported>',
        'quillAttrValue': '<unsupported>',
        'hasQuillEmbed': false,
        'quillEmbedName': '<unsupported>',
        'quillEmbedValue': '<unsupported>',
        'target': 'ApplyTarget.text',
        'attribute': null,
        'children': [
          {
            'start': 7,
            'end': 10,
            'open': '[',
            'close': ']',
            'name': '*',
            'selfClosed': true,
            'selfClosedAtTail': false,
            'hasQuillAttr': true,
            'quillAttrName': 'list',
            'quillAttrValue': 'bullet',
            'hasQuillEmbed': false,
            'quillEmbedName': '<unsupported>',
            'quillEmbedValue': '<unsupported>',
            'target': 'ApplyTarget.paragraph',
            'attribute': null,
            'children': <BBCodeTag>[],
          },
          {'start': 10, 'end': 12, 'text': 'a'},
        ],
      });
    });

    test('parsing simple ordered tag', () {
      const input = '''
[list=1]
[*]a
[/list]
      ''';
      final tag = buildSingleTag(input: input);
      expect(tag.toJson(), {
        'start': 0,
        'end': 21,
        'open': '[',
        'close': ']',
        'name': 'list',
        'selfClosed': false,
        'selfClosedAtTail': false,
        'hasQuillAttr': false,
        'quillAttrName': '<unsupported>',
        'quillAttrValue': '<unsupported>',
        'hasQuillEmbed': false,
        'quillEmbedName': '<unsupported>',
        'quillEmbedValue': '<unsupported>',
        'target': 'ApplyTarget.text',
        'attribute': '1',
        'children': [
          {
            'start': 9,
            'end': 12,
            'open': '[',
            'close': ']',
            'name': '*',
            'selfClosed': true,
            'selfClosedAtTail': false,
            'hasQuillAttr': true,
            'quillAttrName': 'list',
            'quillAttrValue': 'ordered',
            'hasQuillEmbed': false,
            'quillEmbedName': '<unsupported>',
            'quillEmbedValue': '<unsupported>',
            'target': 'ApplyTarget.paragraph',
            'attribute': null,
            'children': <BBCodeTag>[],
          },
          {'start': 12, 'end': 14, 'text': 'a'},
        ],
      });
    });
  });

  test('parsing single line tag', () {
    const input = '[list][*]a[/list]';
    final tag = buildSingleTag(input: input);
    expect(tag.toJson(), {
      'start': 0,
      'end': 17,
      'open': '[',
      'close': ']',
      'name': 'list',
      'selfClosed': false,
      'selfClosedAtTail': false,
      'hasQuillAttr': false,
      'quillAttrName': '<unsupported>',
      'quillAttrValue': '<unsupported>',
      'hasQuillEmbed': false,
      'quillEmbedName': '<unsupported>',
      'quillEmbedValue': '<unsupported>',
      'target': 'ApplyTarget.text',
      'attribute': null,
      'children': [
        {
          'start': 6,
          'end': 9,
          'open': '[',
          'close': ']',
          'name': '*',
          'selfClosed': true,
          'selfClosedAtTail': false,
          'hasQuillAttr': true,
          'quillAttrName': 'list',
          'quillAttrValue': 'bullet',
          'hasQuillEmbed': false,
          'quillEmbedName': '<unsupported>',
          'quillEmbedValue': '<unsupported>',
          'target': 'ApplyTarget.paragraph',
          'attribute': null,
          'children': <BBCodeTag>[],
        },
        {'start': 9, 'end': 10, 'text': 'a'},
      ],
    });
  });

  test('parsing nested tags', () {
    const input = '''
[list]
[*]a
[*][color=#aabbcc]b[/color][/list]''';
    final tag = buildSingleTag(input: input);
    expect(tag.children.length, equals(4));
    expect(tag.children[0].name, equals('*'));
    expect(tag.children[1].isPlainText, equals(true));
    expect(tag.children[1].data, equals('a'));
    expect(tag.children[2].name, equals('*'));
    expect(tag.children[3].name, equals('color'));
    expect(tag.children[3].attribute, equals('#aabbcc'));
    expect(tag.children[3].children.length, equals(1));
    expect(tag.children[3].children[0].isPlainText, equals(true));
    expect(tag.children[3].children[0].data, equals('b'));
  });

  test('fallback embed content', () {
    {
      const input = '''
[list]
[*][code]a[/code][/list]''';
      final tag = buildSingleTag(input: input);
      expect(tag.children.length, equals(2));
      expect(tag.children[0].name, equals('*'));
      expect(tag.children[1].isPlainText, equals(true));
      expect(tag.children[1].data, equals('[code]a[/code]'));
    }

    {
      const input = '''
[list]
[*][spoiler=a]a[/spoiler][/list]''';
      final tag = buildSingleTag(input: input);
      expect(tag.children.length, equals(4));
      expect(tag.children[0].name, equals('*'));
      expect(tag.children[1].isPlainText, equals(true));
      expect(tag.children[1].data, equals('[spoiler=a]'));
      expect(tag.children[2].isPlainText, equals(true));
      expect(tag.children[2].data, equals('a'));
      expect(tag.children[3].isPlainText, equals(true));
      expect(tag.children[3].data, equals('[/spoiler]'));
    }
  });

  test('back to BBCode', () {
    const input = '''
[list]
[*]
[*][color=#00FF00]b[/color]
[/list]''';
    final tags = parseBBCodeTextToTags(input);
    final output = convertBBCodeToText(tags);
    expect(output, equals(input));
  });

  test('normalize Delta', () {
    const input = '''
[list]
[*]
[*][color=#00FF00]b[/color]
[/list]''';
    final deltas = parseBBCodeTextToDelta(input);
    expect(
      deltas.toJson(),
      equals([
        {'insert': '', 'attributes': <String, dynamic>{}},
        {'insert': ''},
        {'insert': '', 'attributes': <String, dynamic>{}},
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        },
        {
          'insert': 'b',
          'attributes': {'color': '#00FF00'},
        },
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        },
      ]),
    );
  });
}
