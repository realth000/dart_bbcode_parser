import 'package:dart_bbcode_parser/src/quill/convertible.dart';
import 'package:test/test.dart';

void main() {
  group('quill convertible functionality', () {
    test('unused situations', () {
      const attr1 = QuillAttribute('a-name', 'a-value');
      const attr2 = QuillAttribute('a-name', 'a-value');
      const attr3 = QuillAttribute('b-name', 'b-value');
      expect(attr1 == attr1, equals(true));
      expect(attr1 == attr2, equals(true));
      expect(attr1 == attr3, equals(false));
      expect(attr1.hashCode.runtimeType, equals(int));
      expect(attr1.toString(), equals('QuillAttribute { name="a-name", value="a-value" }'));
    });
  });
}
