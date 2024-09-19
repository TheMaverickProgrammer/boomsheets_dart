import 'dart:math';
import 'package:boomsheets/src/labeled_point.dart';
import 'package:boomsheets/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

typedef KeyframeRect = ({Point<int> pos, Point<int> size});

/// A [Keyframe] represents a [rect] on a spritesheet.
///
/// The [rect] can also have a relative [origin] which should
/// offset the final image at the time of draw.
/// [flipX] flips the sprite horizontally when true.
/// [flipY] flips the sprite vertically when true.
/// [isEmpty] represents an invisible [Keyframe] with no [rect] data.
/// [duration] is how many frames the [rect] should last in [Frametime].
///
/// [flippedRect] is the [rect] after [flipX] and [flipY] transformations.
/// [flippedRect] is the [origin] after [flipX] and [flipY] transformations.
///
/// Keyframes support scene-graph based renderers with child nodes.
/// Therefore, arbitrary [points] with a name stored in [LabeledPoint.label]
/// can be used to attach child nodes at specific locations relative to this
/// frame.
class Keyframe {
  static const Point<int> _pointZeroInt = Point(0, 0);
  static const Point<double> _pointZeroDouble = Point(0.0, 0.0);
  static const KeyframeRect _rectZero =
      (pos: _pointZeroInt, size: _pointZeroInt);

  List<Attribute> attrs = [];
  KeyframeRect rect;
  Point<int> origin;
  Map<String, LabeledPoint> points = {};
  bool flipX;
  bool flipY;
  Frametime duration;
  final bool isEmpty;

  KeyframeRect get flippedRect {
    if (isEmpty) return _rectZero;

    int x = rect.pos.x;
    int y = rect.pos.y;
    int w = rect.size.x;
    int h = rect.size.y;

    if (flipX) {
      x = x + w;
      w = -w;
    }

    if (flipY) {
      y = y + h;
      h = -h;
    }

    return (pos: Point<int>(x, y), size: Point<int>(w, h));
  }

  Point<int> get flippedOrigin {
    if (isEmpty) return _pointZeroInt;

    int x = origin.x;
    int y = origin.y;

    if (flipX) {
      x = rect.size.x - x;
    }

    if (flipY) {
      y = rect.size.y - y;
    }

    return Point<int>(x, y);
  }

  /// If [considerFlip] is true, this method uses [flippedOrigin]
  /// and [flippedRect] for calculating the canonical origin values.
  /// Default value is false.
  ///
  /// This methods transforms [origin] or [flippedOrigin] to
  /// canonical values (0.0,1.0) inclusive.
  ///
  /// Note that origins can be anywhere outside the [rect] or
  /// [flippedRect] and may result in negative or even large
  /// canonical values.
  Point<double> canonicalOrigin({bool considerFlip = false}) {
    if (isEmpty) return _pointZeroDouble;

    final corigin = considerFlip ? flippedOrigin : origin;
    final crect = considerFlip ? flippedRect : rect;
    double w = 0;
    double h = 0;

    if (crect.size.x != 0) {
      w = corigin.x / crect.size.x;
    }

    if (crect.size.y != 0) {
      h = corigin.y / crect.size.y;
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
        rect = (pos: _pointZeroInt, size: _pointZeroInt),
        origin = _pointZeroInt,
        flipX = false,
        flipY = false;

  @override
  String toString() {
    if (isEmpty) {
      return 'empty $duration';
    }

    return 'keyframe={${duration}f, rect={$rect}, $origin, $flipX, $flipY}';
  }
}
