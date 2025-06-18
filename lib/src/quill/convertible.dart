import 'package:meta/meta.dart';

/// A pair of quill attribute.
@immutable
final class QuillAttribute {
  /// Constructor.
  const QuillAttribute(this.name, this.value);

  /// Attribute name.
  final String name;

  /// Attribute value.
  // Insert into attribute map.
  // ignore: avoid_dynamic
  final dynamic value;

  /// Only distinguish attributes on their names.
  @override
  bool operator ==(Object other) => identical(this, other) || (other is QuillAttribute && other.name == name);

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'QuillAttribute { name="$name", value="$value" }';
}

/// Interface requires the conversion between bbcode and quill delta.
abstract interface class QuillConvertible {
  /// Whether current tag has attribute or not.
  bool get hasQuillAttr;

  /// Get the attribute name on current bbcode tag.
  ///
  /// Caller MUST ensure a non-null return value if [hasQuillAttr] is `true`.
  String? get quillAttrName;

  /// Get the attribute value on current bbcode tag.
  ///
  /// Caller MUST ensure a non-null return value if [hasQuillAttr] is `true`.
  // It is the dynamic type.
  // ignore: avoid_dynamic
  dynamic get quillAttrValue;

  /// Using quill embed in quill delta.
  ///
  /// Note that this type of tag is heavily coupled with the implementation of quill delta layer.
  bool get hasQuillEmbed;

  /// The name of embed in delta json.
  String get quillEmbedName;

  /// Embed data.
  String get quillEmbedValue;
}
