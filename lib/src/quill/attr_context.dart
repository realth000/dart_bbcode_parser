import 'package:dart_bbcode_parser/src/quill/convertible.dart';
import 'package:dart_bbcode_parser/src/tags/tag.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// The attributes context go through conversion.
class AttrContext {
  /// Constructor.
  AttrContext({this.attrs = const [], this.operation = const []});

  /// All attrs.
  List<QuillAttribute> attrs;

  /// All operations.
  List<Operation> operation;

  /// Get attrs in map format.
  Map<String, dynamic> get attrMap => Map.fromEntries(attrs.map((e) => MapEntry(e.name, e.value)));

  /// Add attributes into the context.
  //
  // The attribute value is dynamic type according to quill delta definition.
  // ignore: avoid_dynamic
  void _remember(String attrName, dynamic attrValue) {
      attrs.add(QuillAttribute(attrName, attrValue));
  }

  /// Forget last attribute from context.
  void _forget() {
    // Shall not throw empty element exception.
    assert(attrs.isNotEmpty, 'did you forget to save tags?');
    attrs.removeLast();
  }

  /// Save the attribute in [tag] to context.
  void save(BBCodeTag tag) {
    if (!tag.hasQuillAttr) {
      return;
    }
    _remember(tag.quillAttrName!, tag.quillAttrValue);
  }

  /// Remove the attribute in [tag] from context.
  void restore(BBCodeTag tag) {
    if (!tag.hasQuillAttr) {
      return;
    }
    _forget();
  }

  /// Add operations.
  void addOperations(Iterable<Operation> ops) {
    operation.addAll(ops);
  }

  /// Add a single operation.
  void tryAddOperation(Operation? op) {
    if (op == null) {
      return;
    }
    operation.add(op);
  }
}
