import 'package:dart_quill_delta/dart_quill_delta.dart';
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
  bool operator == (Object other) => identical(this, other) || (other is QuillAttribute && other.name != name);

  @override
  int get hashCode => name.hashCode;

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

}


/// Extension on quill delta operations.
extension OperationExt on Operation? {
  /// Get or init an operation
  Operation getOrInit() => this ?? Operation.insert('');

  /// Compose two operation together.
  ///
  /// The [other] operation will be append after current one.
  Operation compose(Operation other) => Operation.insert((this!.data! as String) + (other.data! as String), (this!.attributes ?? {})..addAll(other.attributes ?? {}));
}
