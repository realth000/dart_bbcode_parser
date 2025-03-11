import 'package:dart_bbcode_parser/src/quill/attr_context.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Build the delta from bbcode tags.
Delta buildDelta(List<BBCodeTag> tags) {
  var attrContext = AttrContext();
  for (final tag in tags) {
    attrContext = tag.toQuilDelta(attrContext);
  }
  return Delta.fromOperations(attrContext.operation);
}