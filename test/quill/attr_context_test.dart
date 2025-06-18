import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/align.dart';
import 'package:dart_bbcode_parser/src/tags/bold.dart';
import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/italic.dart';
import 'package:dart_bbcode_parser/src/tags/quote.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/tags/url.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:test/test.dart';

final class FakeParagraphTag extends CommonTag {
  @override
  BBCodeTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) => throw Exception('DO NOT CALL ME');

  @override
  bool get hasQuillAttr => true;

  @override
  String get name => 'fake-paragraph';

  @override
  String? get quillAttrName => 'fake-paragraph-attr-name';

  @override
  String get quillAttrValue => 'fake-paragraph-attr-value';

  @override
  ApplyTarget get target => ApplyTarget.paragraph;
}

void main() {
  group('attribute context', () {
    test('unused situations', () {
      {
        final ac = AttrContext();
        expect(() => ac.restore(UrlTag.empty), throwsUnsupportedError);
        ac.save(BoldTag.empty);
        expect(() => ac.restore(ItalicTag.empty), throwsUnsupportedError);
      }

      {
        final ac = AttrContext();
        expect(() => ac.restore(QuoteTag.empty), throwsUnsupportedError);
        ac.save(FakeParagraphTag());
        expect(() => ac.restore(AlignTag.empty), throwsUnsupportedError);
      }
    });
  });
}
