import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/hide_v2.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:test/test.dart';

import '../utils.dart';

final class FakeCommonParagraphTag extends CommonTag {
  const FakeCommonParagraphTag();

  static const empty = FakeCommonParagraphTag();

  @override
  FakeCommonParagraphTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      const FakeCommonParagraphTag();

  @override
  bool get hasQuillAttr => true;

  @override
  String get name => 'fake-paragraph';

  @override
  String? get quillAttrName => 'fake-paragraph-quill-attr-name';

  @override
  String get quillAttrValue => 'fake-paragraph-quill-attr-value';

  @override
  ApplyTarget get target => ApplyTarget.paragraph;
}

final class FakeEmbedParagraphTag extends EmbedTag {
  const FakeEmbedParagraphTag() : super(start: -1, end: -1);

  static const empty = FakeEmbedParagraphTag();

  @override
  FakeEmbedParagraphTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      FakeEmbedParagraphTag.empty;

  @override
  String get name => 'fake-paragraph';

  @override
  String get quillEmbedName => 'fake-paragraph-embed-name';

  @override
  String get quillEmbedValue => 'fake-paragraph-embed-value';
}

void main() {
  group('common tag interface', () {
    test('check bold tag default values', () {
      final tag = buildSingleTag(input: '[b][/b]');
      expect(tag.runtimeType, equals(BoldTag));
      expect(() => tag.data, throwsUnsupportedError);
      expect(tag.open, equals('['));
      expect(tag.close, equals(']'));
      expect(tag.selfClosedAtTail, equals(false));
      expect(tag.hasQuillEmbed, equals(false));
      expect(() => tag.quillEmbedName, throwsUnsupportedError);
      expect(() => tag.quillEmbedValue, throwsUnsupportedError);
      expect(tag.attributeValidator, equals(nullAttributeValidator));
    });

    test('check embed tag default values', () {
      final tag = buildSingleTag(input: '[/hide]');
      expect(tag.runtimeType, equals(HideV2TailTag));
      expect(() => tag.data, throwsUnsupportedError);
      expect(tag.open, equals('['));
      expect(tag.close, equals(']'));
      expect(tag.hasQuillAttr, equals(false));
      expect(() => tag.quillAttrName, throwsUnsupportedError);
      expect(() => tag.quillAttrValue, throwsUnsupportedError);
      expect(tag.hasQuillEmbed, equals(true));
      expect(tag.childrenValidator, equals(null));
    });

    test('in unused implementation situations', () {
      {
        // Ensure paragraphs are prefixed with new line.
        // Test for `ac.addOperations([Operation.insert('\n')]);`
        final tag = buildSingleTag(
          input: '[fake-paragraph][/fake-paragraph]',
          supportedTags: [FakeCommonParagraphTag.empty],
        );
        expect(tag.runtimeType, equals(FakeCommonParagraphTag));
        expect(tag.isPlainText, equals(false));
        final ac = AttrContext()..addOperations([Operation.insert('', {})]);
        tag.toQuilDelta(ac);
        expect(ac.operation.length, equals(4));
        expect(ac.operation.first.toJson(), equals(Operation.insert('', {}).toJson()));
        expect(
          ac.operation.last.toJson(),
          equals(
            Operation.insert('\n', {'fake-paragraph-quill-attr-name': 'fake-paragraph-quill-attr-value'}).toJson(),
          ),
        );
      }

      {
        // Ensure embed tags inside children have attr.
        final tag = buildSingleTag(
          input: '[fake-paragraph][/fake-paragraph]',
          supportedTags: [FakeEmbedParagraphTag.empty],
        );
        expect(tag.runtimeType, equals(FakeEmbedParagraphTag));
        expect(tag.isPlainText, equals(false));
        final ac = AttrContext()..save(const AlignTag(start: 0, end: 0, attribute: 'center'));
        tag.toQuilDelta(ac);
        expect(ac.operation.length, equals(2));
        expect(
          ac.operation.first.toJson(),
          equals(Operation.insert({'fake-paragraph-embed-name': 'fake-paragraph-embed-value'}, {}).toJson()),
        );
        expect(ac.operation.last.toJson(), equals(Operation.insert('\n', {'align': 'center'}).toJson()));
      }
    });
  });
}
