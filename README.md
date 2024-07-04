# Boomsheets for Dart
`Boomsheets` is a human-readable animation file format for all game developers.

## Boomsheets + Flame engine!
If you want to use your animation doc with the Flame engine, 
it is recommended to use the package [Boomflame][BOOMFLAME] which
uses this library and implements all the logic necessary to begin
bringing your animations to life!

## What Boomsheets Solves
Most programmers use multiple images to represent individual frames.
This is neither optimal, work efficient, nor GPU-friendly. 

Others use a spritesheet where all the frames are the exact same width
and height. This is a problem when some animations have a large frame
in the sequence and forces all other frames to become greedy and waste
space.

[Boomsheets Editor][BOOMSHEETS_STEAM] solves these pain points by **empowering**
game devs to select the slices in the spritesheet and reposition frames using
offsets embedded into the document. Visit the [Steam page][BOOMSHEETS_STEAM]
for more information. The generated document is available to use
without the tool.

# Keywords
Boomsheets uses the [YES scriptlet standard][YES_GIT] to define keywords
which allow anyone to read, write, and use the animation document
with only a text editor.

## Globals
Global elements are used as meta information and, if present, apply 
to the whole document.

* `image_path` - Can be read to find the associated image atlas.
* `frame_rate` - Can be read to convert keyframe durations. Default is 60hz.

## Animation keywords
* `anim` - Represents an animation state and requires a string `state`.
* `keyframe` - Represents one frame in the animation.
* `point` - Represents a custom point in the frame.
  * **NOTE**: Defining a point in a frame implicitly defines on in all frames for that animation.

## Using your own custom meta data
The underlining spec used to parse the boomsheets animation document allows
users to provide additional metadata to any of the 3 keywords defined above.
Metadata in the spec are called "Attributes" and begin with the `@` symbol
and must come _before_ one of the animation keywords that they affect. 
They also stack so that multiple attributes can be applied to an element!

> **NOTE**: Attributes by themselves do not do anything! It is the coder's
> responsibility to read the attribute key-values and act on them.

### Metadata on animations
```r
# During this animation drop a hitbox to hurt enemies every frame
@hitbox x=0, y=-10, w=100, h=100
anim JUMP_SPIN_ATTACK
frame ...
frame ...
frame ...
```

### Metadata on keyframes
```r
# When the foot makes contact with the ground, play a sound
anim WALK
frame ...
@play_sound "footsteps.wav" once
frame ...
frame ...
```

### Metadata on points
```r
# The HAND node glows by a percentile 0.0-1.0 during this animation
anim AIM
frame ...
@glow 0.1
point HAND ...
frame ...
@glow 0.5
point HAND ...
frame ...
@glow 1.0
point HAND ...
```

# Getting Started
The entry class for reading any animation document is through `DocumentReader`.
This class provides two static methods: one reads from a file and the other
to reads a document's **contents** from a single `String` with newlines.

Both operations are `async` and will return a `Document` containing the parsed
animation states, keyframe data, and points. They can be used right away.

```dart
void main() async {
  Document doc = await DocumentReader.fromFile(
    File.fromUri(
      Uri.parse("examples/test.anim"),
    ),
  );

  // for each (String key, Anim value) in the doc
  for (final MapEntry(:key, :value) in doc.states.entries) {
    // Anims can have attribute metadata too
    for (final attr in value.attrs) {
      print(attr);
    }
    print("state=$key");
    // Print each keyframe and their attributes, if any
    for (final keyframe in value.keyframes) {
      for (final attr in keyframe.attrs) {
        print(attr);
      }
      print(keyframe);
    }
  }
}
```

# License
This project is licensed under the [Common Development and Distribution License (CDDL)][LEGAL].

[BOOMFLAME]: ./
[BOOMSHEETS_STEAM]: https://store.steampowered.com/app/2189000/BoomSheets/
[LEGAL]: https://github.com/TheMaverickProgrammer/boomsheets_dart/blob/master/LICENSE
[YES_GIT]: https://github.com/TheMaverickProgrammer/dart_yes_parser/blob/master/spec/README.md