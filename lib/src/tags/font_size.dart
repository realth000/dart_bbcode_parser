import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// Tag name.
class FontSizeTag extends CommonTag {
  /// Constructor.
  const FontSizeTag({required super.start, required super.end, required String attribute, super.children})
    : super(attribute: attribute);

  /// Build empty one.
  static const empty = FontSizeTag(start: -1, end: -1, attribute: '');

  /// Allowed font sizes.
  ///
  /// This value is synced with bbcode editor.
  /// TODO: Decouple default font size values.
  static final sizeMap = <String, double>{
    // x-small
    '1': 11.0,
    // small
    '2': 14.0,
    // medium
    '3': 17.0,
    // large
    '4': 19.0,
    // x-large
    '5': 25.0,
    // xx-large
    '6': 33.0,
    // xxx-large
    '7': 49.0,
    // Not set
    '0': 0,
  };

  @override
  String get name => 'size';

  @override
  bool get hasQuillAttr => true;

  @override
  AttributeValidator get attributeValidator => (size) => size != null && sizeMap.containsKey(size);

  @override
  String get quillAttrName => 'size';

  @override
  double get quillAttrValue => sizeMap[attribute!]!;

  @override
  FontSizeTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children) =>
      FontSizeTag(start: head.start, end: tail?.end ?? head.end, attribute: head.attribute!, children: children);
}
