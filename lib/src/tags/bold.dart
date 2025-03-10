import 'package:dart_bbcode_parser/src/tags/common_tag.dart';

/// Tag name.
class BoldTag extends NoAttrTag {
  /// Constructor.
  const BoldTag();

  @override
  String get name => 'b';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'bold';

  @override
  bool get quillAttrValue => true;
}
