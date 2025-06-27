# dart_bbcode_parser

[![codecov](https://codecov.io/gh/realth000/dart_bbcode_parser/graph/badge.svg?token=II36HD8NJE)](https://codecov.io/gh/realth000/dart_bbcode_parser)

BBCode parser written in pure dart with Quill Delta integration support.

This package a dependency of [flutter_bbcode_editor], a BBCode editor based on [flutter_quill].

Some tags are prepared for the editor but the package can be used standalone without it, even in pure dart environment (without Flutter).

## WIP

**This package is not ready to publish to pub.dev.**

## Usage

```dart
import 'package:dart_bbcode_parser/src/dart_bbcode_parser.dart';

const code = '[b]bold text[/b]';

// Parse BBCode text to tags, `List<BBCodeTag>` type.
final tags = parseBBCodeTextToTags(code);

// Parsed BoldTag type.
final boldTag = tags[0];
// Parsed TextContent type.
final boldText = boldTag.children[0];

/// Convert BBCode tags to plain text.
final code2 = convertBBCodeToText(tags);

// Or parse BBCode text to Quill Delta.
final delta = parseBBCodeTextToDelta(code);
```

## Features

* [x] Tags
  * [x] Font size `[size=$size]`
  * [x] Font color `[color=$color]`
  * [x] Bold `[b]`
  * [x] Italic `[i]`
  * [x] Underline `[u]`
  * [x] Background color `[backcolor=$color]`
  * [x] Strikethrough `[s]`
  * [x] Superscript `[sup]`
  * [x] Alignment
    * [x] Align left `[align=left]`
    * [x] Align center `[align=center]`
    * [x] Align right `[align=right]`
  * [x] Url `[url]`
  * [x] Image `[img=$width,$height]$image_url[/img]`
  * [x] Spoiler `[spoiler]`
  * [x] Mention user with `[@]$user_name[/@]`
  * [x] Ordered list `[list=1]`
  * [x] Bullet list `[list]`
  * [x] Divider `[hr]`
  * [x] Code block `[code]`
  * [x] Quote block `[quote]`
  * [x] Superscript `[sup]`
  * [x] Spoiler \*
    * [x] Spoiler header `[spoiler=$description]`
    * [x] Spoiler tail `[/spoiler]`
  * [x] Free area \*
    * [x] Free header `[free=$points]` or `[free]`
    * [x] Free tail `[/free]`
  * [x] Hide area \*
    * [x] Hide header `[hide=$points]` or `[hide]`
    * [x] Hide tail `[/hide]`
* [x] Override tags
* [x] Custom tags
* [x] Convert BBCode tags to Quill Delta.
* [x] Parse text to BBCode tags.
* [x] Convert BBCode tags back to text.

\* Marked tags are extended for [flutter_bbcode_editor].

[flutter_bbcode_editor]: https://github.com/realth000/flutter_bbcode_editor
[flutter_quill]: https://github.com/singerdmx/flutter-quill
