import 'dart:convert';

import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:meta/meta.dart';
import 'package:string_scanner/string_scanner.dart';

/// Plain text.
@immutable
class TextContent implements BBCodeTag {
  /// Constructor.
  const TextContent({required int start, required int end, required String data})
    : _data = data,
      _start = start,
      _end = end;

  /// Build empty one.
  static const empty = TextContent(start: -1, end: -1, data: '');

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

  @override
  bool get selfClosedAtTail => false;

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
    if (data.isEmpty) {
      return attrContext;
    }
    const lf = 0x0a;
    final attrs = attrContext.attrMap;
    final paragraphAttrs = attrContext.paragraphAttrMap;
    if (paragraphAttrs.isEmpty) {
      // Just insert the text if no paragraph attributes presents.
      attrContext.operation.add(Operation.insert(data, attrContext.attrMap));
      return attrContext;
    }

    // Only contains '\n'.
    if (data.codeUnits.every((e) => e == lf)) {
      attrContext.operation.add(Operation.insert(data, attrContext.paragraphAttrMap));
      return attrContext;
    }

    // From here, we are parsing text that attached paragraph attributes.
    final scanner = StringScanner(data);
    var lastSection = 0;
    while (!scanner.isDone) {
      final curr = scanner.readChar();
      final next = scanner.peekChar(1);
      if (curr == lf && next != lf) {
        // Here is the position to paragraph attributes.
        attrContext.operation.add(
          Operation.insert(scanner.substring(lastSection, scanner.position - 1), attrContext.attrMap),
        );
        attrContext.operation.add(Operation.insert('\n', attrContext.paragraphAttrMap));
        lastSection = scanner.position;
        continue;
      }
    }

    if (lastSection < scanner.position) {
      // Some content not scanned yet, do not miss them.
      attrContext.operation.add(Operation.insert(scanner.substring(lastSection, scanner.position), attrs));
    }
    return attrContext;
  }

  @override
  Map<String, dynamic> toJson() => {'start': start, 'end': end, 'text': data};

  @override
  int get hashCode => Object.hash(start, end, data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextContent && other.start == start && other.end == end && other.data == data);

  @override
  String toString() => jsonEncode(toJson());

  @override
  BBCodeTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      throw Exception('can not build text content from tokens');
}
