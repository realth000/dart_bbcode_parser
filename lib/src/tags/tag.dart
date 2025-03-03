import 'package:dart_bbcode_parser/src/utils.dart';

/// The basic class describes common feature and shape on all kinds of tags.
abstract interface class BBCodeTag {
  /// Constructor.
  BBCodeTag({required this.attributeParser, required this.childrenValidator, this.attribute});

  /// The tag name.
  String get name;

  /// Open tag character.
  String get open;

  /// Close tag character.
  String get close;

  /// Whether the tag is self closed.
  ///
  /// For example `[url][/url]` is not self closing because it needs a separate close tag `[/url]` and `[hr]` is self
  /// closing because it does not need one.
  bool get selfClosed;

  /// Function to validate a attribute.
  final AttributeValidator? attributeParser;

  /// Attribute in the open tag.
  String? attribute;

  /// Optional validator on children tags.
  ///
  /// If a tag constraints its children elements to be in some given format, use this function to validate it.
  ///
  /// Return true if children format is valid, or false if children is invalid.
  /// Returning a false value will cause the tag breaks into raw text, instead of tag.
  final ChildrenValidator? childrenValidator;

  // /// Contains a list of tags that are not allowed in children context.
  // final List<BBCodeTag> disallowedChildren;
}
