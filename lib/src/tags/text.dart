import 'dart:convert';

import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:string_scanner/string_scanner.dart';

/// Plain text.
class TextContent implements BBCodeTag {
  /// Constructor.
  TextContent({required this.start, required this.end, required this.data, this.isIgnored = false});

  /// Build from originanl input text with given ranges index from [start] to [end].
  factory TextContent.fromOriginalInput({required String originalString, required int start, required int end}) =>
      TextContent(start: start, end: end, data: originalString.substring(start, end));

  /// Build empty one.
  static final empty = TextContent(start: -1, end: -1, data: '');

  /// Flag indicating the text is ignored in parsing or not.
  ///
  /// When text is ignored, it only lives in BBCode parsing stage. When convert to other formats, these
  /// text are ignored. e.g. not produce Operations in Quill Delta.
  ///
  /// It's useful to "restore" ignored text back to plain text if process is fallbacking.
  bool isIgnored;

  /// Data content.
  @override
  String data;

  @override
  bool get isPlainText => true;

  @override
  String get attribute => throw UnsupportedError('shall not call named tag related method on plain text tag');

  @override
  AttributeValidator get attributeValidator =>
      throw UnsupportedError('shall not call attribute related method on plain text tag');

  @override
  ChildrenValidator get childrenValidator =>
      throw UnsupportedError('shall not call children validator on plain text tag');

  @override
  ParentValidator? get parentValidator => throw UnsupportedError('shall not call parent validator on plain text tag');

  @override
  String get open => throw UnsupportedError('shall not call open getter on plain text tag');

  @override
  String get close => throw UnsupportedError('shall not call close getter on plain text tag');

  @override
  bool get hasQuillAttr => false;

  @override
  String get name => throw UnsupportedError('shall not call named getter on plain text tag');

  @override
  String get quillAttrName => throw UnsupportedError('shall not call quill attr related method on plain text tag');

  @override
  String get quillAttrValue => throw UnsupportedError('shall not call quill attr related method on plain text tag');

  @override
  bool get hasQuillEmbed => false;

  @override
  String get quillEmbedName => throw UnsupportedError('shall not call quill embed related method on plain text tag');

  @override
  String get quillEmbedValue => throw UnsupportedError('shall not call quill embed related method on plain text tag');

  @override
  bool get selfClosed => throw UnsupportedError('shall not call closing related method on plain text tag');

  @override
  bool get selfClosedAtTail => throw UnsupportedError('shall not call closing related method on plain text tag');

  @override
  int start;

  @override
  int end;

  @override
  ApplyTarget get target => throw UnsupportedError('text has no apply target');

  @override
  StringBuffer toBBCode(StringBuffer buffer) {
    buffer.write(data);
    return buffer;
  }

  @override
  AttrContext toQuilDelta(AttrContext attrContext) {
    if (data.isEmpty || isIgnored) {
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
  Map<String, dynamic> toJson() => {'start': start, 'end': end, 'text': data, if (isIgnored) 'isIgnored': true};

  @override
  String toString() => jsonEncode(toJson());

  @override
  BBCodeTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children) =>
      throw UnsupportedError('can not build text content from tokens');

  @override
  String attributeBBCode() => throw UnsupportedError('can not call attribute methods on plain text');

  @override
  void fallbackToText(StringBuffer buffer) => buffer.write(data);

  @override
  // We have to override it.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(start, end, data, isIgnored);

  @override
  // We have to override it.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextContent &&
          other.start == start &&
          other.end == end &&
          other.data == data &&
          other.isIgnored == isIgnored);

  @override
  // List<BBCodeTag> children = throw UnsupportedError('shall not call children getter on plain text tag');
  List<BBCodeTag> children = [];
}
