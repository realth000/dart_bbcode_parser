# dart_bbcode_parser

[![codecov](https://codecov.io/gh/realth000/dart_bbcode_parser/graph/badge.svg?token=II36HD8NJE)](https://codecov.io/gh/realth000/dart_bbcode_parser)

BBCode parser written in pure dart with Quill Delta integration support.

This package is dependent of [flutter_bbcode_editor].

## WIP

**This package is still in early stage.**

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

* [ ] Tags
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
  * [ ] Ordered list `[list=1]`
  * [ ] Bullet list `[list]`
  * [x] Divider `[hr]`
  * [ ] Table `[table]` & `[tr]` & `[td]`
  * [x] Code block `[code]`
  * [x] Quote block `[quote]`
  * [x] Superscript `[sup]`
  * [x] Spoiler (extended for [flutter_bbcode_editor])
    * [x] Spoiler header `[spoiler=$description]`
    * [x] Spoiler tail `[/spoiler]`
  * [x] Free area (extended for [flutter_bbcode_editor])
    * [x] Free header `[free=$points]` or `[free]`
    * [x] Free tail `[/free]`
  * [x] Hide area (extended for [flutter_bbcode_editor])
    * [x] Hide header `[hide=$points]` or `[hide]`
    * [x] Hide tail `[/hide]`
* [x] Override tags
* [x] Custom tags
* [x] Convert BBCode tags to Quill Delta.
* [x] Parse text to BBCode tags.
* [x] Convert BBCode tags back to text.

[flutter_bbcode_editor]: https://github.com/realth000/flutter_bbcode_editor