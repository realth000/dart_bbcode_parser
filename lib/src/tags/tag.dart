import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dart_bbcode_parser/src/constants.dart';
import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/quill/convertible.dart';
import 'package:dart_bbcode_parser/src/token.dart';
import 'package:dart_bbcode_parser/src/utils.dart';
import 'package:meta/meta.dart';

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
@immutable
abstract class BBCodeTag implements QuillConvertible {
  /// Constructor.
  const BBCodeTag({
    required this.attributeValidator,
    required this.childrenValidator,
    int? start,
    int? end,
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

  /// Where the tag is self closed, if is a tail token, set to true.
  ///
  /// This field is ignored when [selfClosed] is false.
  bool get selfClosedAtTail;

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
    if (!(selfClosed && selfClosedAtTail)) {
      buffer.write('[$name${attribute != null ? "=$attribute" : ""}]');
    }
    for (final e in children) {
      e.toBBCode(buffer);
    }
    if (!selfClosed || (selfClosed && selfClosedAtTail)) {
      buffer.write('[/$name]');
    }
    return buffer;
  }

  /// Convert contents to single.
  ///
  /// ## CAUTION
  ///
  /// Recurse stack overflow.
  AttrContext toQuilDelta(AttrContext attrContext);

  /// Build one from token.
  ///
  /// Note that in parsing process, this function is called **BEFORE** attribute passed validation.
  BBCodeTag fromToken(TagHead? head, TagTail? tail, List<BBCodeTag> children);

  /// Fallback the current tag to plain text and save the result in [buffer], children tags are also affected.
  void fallbackToText(StringBuffer buffer) {
    if (selfClosed) {
      if (selfClosedAtTail) {
        buffer.write('$open$name$close');
      } else {
        buffer.write('$open${K.slash}$name$close');
      }
      // Self closing tags do not have children so the process is finished.
    } else {
      buffer.write('$open$name${attributeBBCode()}$close');
      for (final child in children) {
        child.fallbackToText(buffer);
      }
      buffer.write('$open${K.slash}$name$close');
    }
  }

  /// Get the attribute represented in BBCode format to use directly in data.
  ///
  /// * If not null, prepend a '='.
  /// * If null, return empty string.
  String attributeBBCode() {
    if (attribute == null) {
      return '';
    } else {
      return '=$attribute';
    }
  }

  /// To json string.
  Map<String, dynamic> toJson() => {
    'start': start,
    'end': end,
    'open': open,
    'close': close,
    'name': name,
    'selfClosed': selfClosed,
    'selfClosedAtTail': selfClosedAtTail,
    'hasQuillAttr': hasQuillAttr,
    'quillAttrName': hasQuillAttr ? quillAttrName : K.unsupported,
    'quillAttrValue': hasQuillAttr ? quillAttrValue : K.unsupported,
    'hasQuillEmbed': hasQuillEmbed,
    'quillEmbedName': hasQuillEmbed ? quillEmbedName : K.unsupported,
    'quillEmbedValue': hasQuillEmbed ? quillEmbedValue : K.unsupported,
    'target': '$target',
    'attribute': attribute,
    'children': children.map((e) => e.toJson()).toList(),
  };

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! BBCodeTag) {
      return false;
    }

    const comparator = ListEquality<BBCodeTag>(DefaultEquality<BBCodeTag>());
    return comparator.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(open, close, name, start, end, selfClosed, selfClosedAtTail, target, children);
}
