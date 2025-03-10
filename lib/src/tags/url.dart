import 'package:dart_bbcode_parser/src/tags/common_tag.dart';
import 'package:dart_bbcode_parser/src/utils.dart';

/// Url tag holds a content and link to it.
///
/// ```console
/// [url=$URL]$CHILDREN[/url]
/// ```
class UrlTag extends CommonTag {
  /// Constructor.
  const UrlTag({super.children});

  /// Url shall not be empty.
  @override
  AttributeValidator get attributeParser => (input) => input.isNotEmpty;

  @override
  String get name => 'url';

  @override
  bool get hasQuillAttr => true;

  @override
  String get quillAttrName => 'link';

  @override
  String get quillAttrValue => attribute!;
}
