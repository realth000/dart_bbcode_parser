import 'package:dart_bbcode_parser/src/constants.dart';

/// Extension on [int] type.
extension IntExt on int? {
  /// Check is [K.open] or not.
  bool get isOpen => this == K.openCode;

  /// Check is [K.close] or not.
  bool get isClose => this == K.closeCode;

  /// Check is [K.slash] or not.
  bool get isSlash => this == K.slashCode;

  //// Check is [K.equal] or not.
  bool get isEqual => this == K.equalCode;
}
