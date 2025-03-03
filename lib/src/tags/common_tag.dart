import 'package:dart_bbcode_parser/src/tags/tag.dart';

/// Common common and base tags.
abstract class CommonTag implements BBCodeTag {
  @override
  String get open => '[';

  @override
  String get close => ']';

  @override
  bool get selfClosed => false;

  /// Initial attribute value is `null`.
  @override
  String? attribute;

  @override
  bool Function(String input)? get childrenValidator => null;
}

/// Tag with no attribute.
abstract class NoAttrTag extends CommonTag {
  @override
  String? get attribute => null;

  @override
  bool Function(String input)? get attributeParser => null;
}
