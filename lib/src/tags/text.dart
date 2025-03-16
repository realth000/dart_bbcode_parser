import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:meta/meta.dart';

/// Plain text.
@immutable
class TextContent implements BBCodeTag {
  /// Constructor.
  const TextContent(int start, int end, String data) : _data = data, _start = start, _end = end;

  /// Build empty one.
  factory TextContent.empty() => const TextContent(-1, -1, '');

  /// Data content.
  final String _data;

  @override
  bool get isPlainText => true;

  @override
  String get data => _data;

  @override
  String get attribute => throw Exception('shall not call named tag related method on plain text tag');

  @override
  AttributeValidator get attributeValidator =>
      throw Exception('shall not call named tag related method on plain text tag');

  @override
  List<BBCodeTag> get children => throw Exception('shall not call named tag related method on plain text tag');

  @override
  ChildrenValidator get childrenValidator =>
      throw Exception('shall not call named tag related method on plain text tag');

  @override
  String get open => throw Exception('shall not call named tag related method on plain text tag');

  @override
  String get close => throw Exception('shall not call named tag related method on plain text tag');

  @override
  bool get hasQuillAttr => false;

  @override
  String get name => throw Exception('shall not call named tag related method on plain text tag');

  @override
  String get quillAttrName => throw Exception('shall not call quill attr related method on plain text tag');

  @override
  String get quillAttrValue => throw Exception('shall not call quill attr related method on plain text tag');

  @override
  bool get hasQuillEmbed => false;

  @override
  String get quillEmbedName => throw UnsupportedError('shall not call quill embed related method on plain text tag');

  @override
  String get quillEmbedValue => throw UnsupportedError('shall not call quill embed related method on plain text tag');

  @override
  bool get selfClosed => true;

  final int _start;

  @override
  int get start => _start;

  final int _end;

  @override
  int get end => _end;

  @override
  ApplyTarget get target => throw UnsupportedError('text has no apply target');

  @override
  StringBuffer toBBCode(StringBuffer buffer) {
    buffer.write(_data);
    return buffer;
  }

  @override
  AttrContext toQuilDelta(AttrContext attrContext) {
    final attrs = attrContext.attrMap;
    attrContext.operation.add(Operation.insert(data, attrContext.attrMap));
    return attrContext;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is TextContent && other.data == data);

  @override
  String toString() => 'TextContent { data=$_data }';

  @override
  BBCodeTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      throw Exception('can not build text content from tokens');
}
