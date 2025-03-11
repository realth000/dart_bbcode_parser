import 'package:collection/collection.dart';
import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';

/// Common common and base tags.
///
/// Defines open character, close character, self closing and children validator.
abstract class CommonTag extends BBCodeTag {
  /// Constructor.
  const CommonTag({super.attribute, super.children, super.attributeParser, super.childrenValidator});

  @override
  bool get hasPlainText => false;

  @override
  String get data => throw Exception('shall not calling data on non-plain-text tag');

  @override
  String get open => '[';

  @override
  String get close => ']';

  @override
  bool get selfClosed => false;

  @override
  bool Function(String input)? get childrenValidator => null;

  @override
  AttrContext toQuilDelta(AttrContext attrContext) {
    var ac = AttrContext();
    for (final child in (children ?? const <BBCodeTag>[])) {
      attrContext.save(this);
      ac = child
          .toQuilDelta(attrContext)
        ..restore(this);
    }
    return ac;
  }

  @override
  String toString() => '''
$runtimeType {
    open="$open",
    close="$close",
    selfClosed=$selfClosed,
    attr=${attribute != null ? "$attribute" : null}
    children = ${ children?.map((e) => e.toString()).join('\n')}
}''';
}

/// Tag with no attribute.
abstract class NoAttrTag extends CommonTag {
  /// Constructor.
  const NoAttrTag({super.children, super.attributeParser, super.childrenValidator,});

  @override
  String? get attribute => null;

  @override
  bool Function(String input)? get attributeParser => null;
}
