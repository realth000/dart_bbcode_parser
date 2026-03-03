import 'package:dart_bbcode_parser/src/tags/tag.dart';

/// Function validating tag attributes.
typedef AttributeValidator = bool Function(String? input);

/// Use this validator when attribute is not allowed.
bool nullAttributeValidator(String? attr) => attr == null;

/// Function validating tag children contents.
typedef ChildrenValidator = bool Function(List<BBCodeTag> input);

/// Function validating tag's parent.
///
/// Return `true` if parent is valid, or `false` if parent is invalid.
typedef ParentValidator = bool Function(BBCodeTag? parent);
