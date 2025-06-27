import 'dart:convert';

import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/text.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('text content', () {
    test('unused situations', () {
      final tag = buildSingleTag(input: 'text_content');
      expect(tag.runtimeType, equals(TextContent));
      expect(() => tag.attribute, throwsUnsupportedError);
      expect(() => tag.attributeValidator, throwsUnsupportedError);
      expect(() => tag.children, throwsUnsupportedError);
      expect(() => tag.childrenValidator, throwsUnsupportedError);
      expect(() => tag.open, throwsUnsupportedError);
      expect(() => tag.close, throwsUnsupportedError);
      expect(tag.hasQuillAttr, false);
      expect(() => tag.name, throwsUnsupportedError);
      expect(() => tag.quillAttrName, throwsUnsupportedError);
      expect(() => tag.quillAttrValue, throwsUnsupportedError);
      expect(tag.hasQuillEmbed, false);
      expect(() => tag.quillEmbedName, throwsUnsupportedError);
      expect(() => tag.quillEmbedValue, throwsUnsupportedError);
      expect(() => tag.selfClosed, throwsUnsupportedError);
      expect(() => tag.selfClosedAtTail, throwsUnsupportedError);
      expect(() => tag.target, throwsUnsupportedError);
      expect(tag.attributeBBCode, throwsUnsupportedError);
      final targetData = {'start': 0, 'end': 12, 'text': 'text_content'};
      expect(tag.toJson(), equals(targetData));
      expect(tag.toString(), equals(jsonEncode(targetData)));
      expect(tag.hashCode.runtimeType, equals(int));
      expect(() => tag.fromToken(null, null, const []), throwsUnsupportedError);

      {
        // If all characters in text are '\n' and paragraph attribute attached, only keep a new '\n' and reserve the
        // paragraph attribute.
        final tag = buildSingleTag(input: '\n');
        final ac = AttrContext()..save(const AlignTag(start: 0, end: 0, attribute: 'center'));
        tag.toQuilDelta(ac);
        expect(ac.operation.length, 1);
        expect(ac.operation.last.toJson(), equals(Operation.insert('\n', {'align': 'center'}).toJson()));
      }

      {
        // If not all characters in text are '\n', keep the text here, and split the last '\n' into the last paragraph
        // to ensure delta ended with '\n', and don't forget those attributes.
        final tag = buildSingleTag(input: '1\n2\n');
        final ac =
            AttrContext()
              ..save(const BoldTag(start: 0, end: 0))
              ..save(const AlignTag(start: 0, end: 0, attribute: 'center'));
        tag.toQuilDelta(ac);
        expect(ac.operation.length, 2);
        expect(ac.operation.first.toJson(), equals(Operation.insert('1\n2', {'bold': true}).toJson()));
        expect(ac.operation.last.toJson(), equals(Operation.insert('\n', {'align': 'center'}).toJson()));
      }
    });
  });
}
