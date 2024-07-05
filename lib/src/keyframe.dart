import 'dart:math';
import 'package:boomsheets/src/labeled_point.dart';
import 'package:boomsheets/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

/// A [Keyframe] represents a [rect] on a spritesheet.
///
/// The [rect] can also have a relative [origin] which should
/// offset the final image at the time of draw.
/// [flipX] flips the sprite horizontally when true.
/// [flipY] flips the sprite vertically when true.
/// [isEmpty] represents an invisible [Keyframe] with no [rect] data.
/// [duration] is how many frames the [rect] should last in [Frametime].
///
/// [computeRect] is the [rect] after [flipX] and [flipY] transformations.
/// [computeOrigin] is the [origin] after [flipX] and [flipY] transformations.
///
/// Keyframes support scene-graph based renderers with child nodes.
/// Therefore, arbitrary [points] with a name stored in [LabeledPoint.label]
/// can be used to attach child nodes at specific locations relative to this
/// frame.
class Keyframe {
  static const Point<int> _pointZeroInt = Point(0, 0);
  static const Point<double> _pointZeroDouble = Point(0.0, 0.0);
  static const Rectangle<int> _rectZero = Rectangle(0, 0, 0, 0);

  List<Attribute> attrs = [];
  Rectangle<int> rect;
  Point<int> origin;
  Map<String, LabeledPoint> points = {};
  bool flipX;
  bool flipY;
  Frametime duration;
  final bool isEmpty;

  Rectangle<int> get computeRect {
    if (isEmpty) return _rectZero;

    int x = rect.left;
    int y = rect.top;
    int w = rect.width;
    int h = rect.height;

    if (flipX) {
      x = x + w;
      w = -w;
    }

    if (flipY) {
      y = y + h;
      h = -h;
    }

    return Rectangle(x, y, w, h);
  }

  Point<int> get computeOrigin {
    if (isEmpty) return _pointZeroInt;

    int x = origin.x;
    int y = origin.y;

    if (flipX) {
      x = rect.width - x;
    }

    if (flipY) {
      y = rect.height - y;
    }

    return Point<int>(x, y);
  }

  /// Transforms [computeOrigin] width and height to canonical values [.0-1.0].
  ///
  /// Note that origins can be anywhere outside the [computeRect] and may
  /// result in negative or even large canonical values.
  Point<double> get canonicalOrigin {
    if (isEmpty) return _pointZeroDouble;

    final corigin = computeOrigin;
    final crect = computeRect;
    double w = 0;
    double h = 0;

    if (crect.width != 0) {
      w = corigin.x / crect.width;
    }

    if (crect.height != 0) {
      h = corigin.y / crect.height;
    }

    return Point<double>(w, h);
  }

  /// Construct a rectangular keyframe [rect] with a [duration] and [origin].
  Keyframe({
    required this.rect,
    required this.origin,
    required this.duration,
    this.flipX = false,
    this.flipY = false,
  }) : isEmpty = false;

  /// Construct an empty, invisible, shapeless keyframe with a [duration].
  Keyframe.empty({required this.duration})
      : isEmpty = true,
        rect = Rectangle.fromPoints(_pointZeroInt, _pointZeroInt),
        origin = _pointZeroInt,
        flipX = false,
        flipY = false;

  @override
  String toString() {
    if (isEmpty) {
      return 'empty $duration';
    }

    return 'keyframe={$duration\f, rect={$rect}, $origin, $flipX, $flipY}';
  }
}
