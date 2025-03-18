import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/quill/convertible.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// Attribute apply on what.
enum ApplyTarget {
  /// On text.
  ///
  /// Default value.
  text,

  /// On paragraph.
  paragraph,
}

/// The basic class describes common feature and shape on all kinds of tags.
abstract class BBCodeTag implements QuillConvertible {
  /// Constructor.
  const BBCodeTag({
    int? start,
    int? end,
    required this.attributeValidator,
    required this.childrenValidator,
    List<BBCodeTag>? children,
    this.attribute,
  }) : _start = start ?? 0,
       _end = end ?? 0,
       children = children ?? const [];

  /// Is plain text or not.
  bool get isPlainText;

  /// Extra plain text data.
  String? get data;

  /// The tag name.
  String get name;

  /// Open tag character.
  String get open;

  /// Close tag character.
  String get close;

  /// Start position.
  final int _start;

  /// Get the start position.
  int get start => _start;

  /// End position.
  final int _end;

  /// Get the end position.
  int get end => _end;

  /// Whether the tag is self closed.
  ///
  /// For example `[url][/url]` is not self closing because it needs a separate close tag `[/url]` and `[hr]` is self
  /// closing because it does not need one.
  bool get selfClosed;

  /// By default the tag applies on text.
  ///
  /// Change to other target if necessary.
  ApplyTarget get target => ApplyTarget.text;

  /// Function to validate a attribute.
  final AttributeValidator? attributeValidator;

  /// Attribute in the open tag.
  final String? attribute;

  /// Optional validator on children tags.
  ///
  /// If a tag constraints its children elements to be in some given format, use this function to validate it.
  ///
  /// Return true if children format is valid, or false if children is invalid.
  /// Returning a false value will cause the tag breaks into raw text, instead of tag.
  final ChildrenValidator? childrenValidator;

  // /// Contains a list of tags that are not allowed in children context.
  // final List<BBCodeTag> disallowedChildren;

  /// All childrens
  final List<BBCodeTag> children;

  /// Function converts current tag into bbcode text.
  ///
  /// ## CAUTION
  ///
  /// Recursing may cause stack overflow.
  StringBuffer toBBCode(StringBuffer buffer) {
    buffer.write('[$name]');
    children?.forEach((e) => e.toBBCode(buffer));
    buffer.write('[/$name]');
    return buffer;
  }

  /// Convert contents to single.
  ///
  /// ## CAUTION
  ///
  /// Recurse stack overflow.
  AttrContext toQuilDelta(AttrContext attrContext);

  /// Transform current bbcode tag into quill delta operation and insert the operation into [queryDelta] so that once
  /// the insertion is finished,
  ///
  /// ## CAUTION
  ///
  /// Recursing may cause stack overflow.
  // void buildQueryDelta(QueryDelta queryDelta) {
  //   queryDelta.insert(insert: Operation.insert().input?, insertAtLastOperation: true, target: null);
  // }

  /// Build one from token.
  BBCodeTag fromToken(TagHead head, TagTail? tail, List<BBCodeTag> children);
}
