import 'package:dart_bbcode_parser/src/tags/tag.dart';

/// Function validating tag attributes.
typedef AttributeValidator = bool Function(String? input);

/// Use this validator when attribute is not allowed.
AttributeValidator nullAttributeValidator = (attr) => attr == null;

/// Function validating tag children contents.
typedef ChildrenValidator = bool Function(List<BBCodeTag> input);
