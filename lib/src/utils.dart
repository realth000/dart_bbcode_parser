import 'package:dart_bbcode_parser/src/tags/tag.dart';

/// Function validating tag attributes.
typedef AttributeValidator = bool Function(String? input);

/// Function validating tag children contents.
typedef ChildrenValidator = bool Function(List<BBCodeTag> input);
