## 1.0.11
- Somehow bumped without the actual change. For real: `options` -> `xtends` from previous version.
- 
## 1.0.10
- Missed `options` -> `xtends` from previous version.
  
## 1.0.9
- VS Code Extension on the market place.
- Extensions (XE) are optional opt-in constructor arguments.
- Added experimental macro support: _XE 2026.1_.
  - Macros are lines starting with `+` and a name.
  - Macros are preprocessed before parsing the doc.

## 1.0.8
- Bumped to `yes_parser` version `1.0.10` which fixes a major issue when parsing carriage returns and tabs in documents.

## 1.0.7

- Bumped to `yes_parser` version `1.0.9`.
- Added `Point<int> Keyframe.flippedPoint(Point<int> point)` to calculate arbitrary points.
- Added `Point<int> Keyframe.pointOffset({required String point})` to calculate encoded point offsets from `Keyframe.origin`.
- More documentation to `Keyframe` class.

## 1.0.6

- Fixed pubspec description typo
- Using YesParser 1.0.8
- Provided .anim doc example for multi-line elements
- Improved readme

## 1.0.5

- Fixed breaking changes from `yes_parser` upstream version `1.0.5`.
- These changes improve parsing edge-case failures previously seen with animations.

## 1.0.4

- Renamed `computeRect` and `computeOrigin` to `flippedRect` and `flippedOrigin`.
- Rewrote `canonicalOrigin` from a getter to a method that takes in an optional `considerFlip`.
- Added github-supported blockquotes to readme.
- Bumped version to use YesParser 1.0.4

## 1.0.3

- Bumped version to use YesParser 1.0.3

## 1.0.2

- Bumped version to use YesParser 1.0.2
- Removed the Point<int> zero extension since static methods are not allowed.
- Changed Keyframe.points to a hashmap with the key as the name of the LabeledPoint element.
- Added Keyframe.computeRect and Keyframe.computeOrigin to transform rect and origin according to flipX and flipY values.
- Showed how to print LabeledPoints in the example.
- Modified the toString() routine on both LabeledPoints and Keyframe classes.

## 1.0.1

- Upstream changed to 1.0.1 required adjustments to call to YesParser.
- Added additional fields to Anim class constructor to create Anims without parsing.

## 1.0.0

- Initial version.
