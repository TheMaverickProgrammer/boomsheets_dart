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
