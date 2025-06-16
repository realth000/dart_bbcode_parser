/// All constants used in this package.
abstract class K {
  K._();

  /// The open character of tag.
  static const open = '[';

  /// Utf-16 character code of [open].
  static const openCode = 0x5b;

  /// The close character of tag.
  static const close = ']';

  /// Utf-16 character code of [close].
  static const closeCode = 0x5d;

  /// The Equal character as a separator between tag name and tag attribute.
  static const equal = '=';

  /// Utf-16 character code of [equal].
  static const equalCode = 0x3d;

  /// Slash here.
  static const slash = '/';

  /// Utf-16 character code of [slash].
  static const slashCode = 0x2f;

  /// Placeholder for unsupported data.
  static const unsupported = '<unsupported>';
}
