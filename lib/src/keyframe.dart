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
///
/// See [Keyframe.pointOffset] to return a calculated [Point] with encoded
/// offset with respect to [Keyframe.origin] of a matching [LabeledPoint].
class Keyframe {
  static const Point<int> _pointZeroInt = Point(0, 0);
  static const Point<double> _pointZeroDouble = Point(0.0, 0.0);
  static const KeyframeRect _rectZero =
      (pos: _pointZeroInt, size: _pointZeroInt);

  /// List of user-defined [Attribute] elements tagged to this [Keyframe].
  List<Attribute> attrs = [];

  /// Represents the position on the texture (x,y) where this
  /// [Keyframe] begins. Combined with a width and height,
  /// represents the visible cell of the sprite at some moment.
  KeyframeRect rect;

  /// Represents the local point (0,0) on the source texture.
  Point<int> origin;

  /// A map of [String] names to [LabeledPoint] points.
  Map<String, LabeledPoint> points = {};

  /// Whether or not this frame is flipped horizontally.
  bool flipX;

  /// Whether or not this frame is flipped vertically.
  bool flipY;

  /// The duration of this [Keyframe] in [Frametime].
  Frametime duration;

  /// Whether or not this [Keyframe] represents a blank frame.
  /// This is useful for flickering effects or hiding a sprite.
  final bool isEmpty;

  /// If this [Keyframe] represents an empty frame e.g. [Keyframe.isEmpty],
  /// then returns [Keyframe._rectZero]. Otherwise, return
  /// [KeyframeRect] with respect to [Keyframe.flipX] and [Keyframe.flipY].
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

  /// Given a [point], returns a new [Point]
  /// with respect to [Keyframe.flipX] and [Keyframe.flipY].
  ///
  /// If both booleans are false, that is there are no flips,
  /// then the new [Point] is equal to exactly [point].
  Point<int> flippedPoint(Point<int> point) {
    int x = point.x;
    int y = point.y;

    if (flipX) {
      x = rect.size.x - x;
    }

    if (flipY) {
      y = rect.size.y - y;
    }

    return Point<int>(x, y);
  }

  /// If this [Keyframe] represents an empty frame e.g. [Keyframe.isEmpty],
  /// then returns [Keyframe._pointZeroInt]. Otherwise, return
  /// [Keyframe.origin] with respect to [Keyframe.flipX] and [Keyframe.flipY].
  Point<int> get flippedOrigin {
    if (isEmpty) return _pointZeroInt;
    return flippedPoint(origin);
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

  /// If the name [point] matches a [LabeledPoint] in this [Keyframe], then
  /// return the calculated offset encoded in [Point] with respect to
  /// [Keyframe.origin]. If no point is found, returns null.
  ///
  /// If [considerFlip] is true, this method uses [Keyframe.flippedPoint]
  /// for calculating the destination point in the equation: `dest - origin`.
  Point<int>? pointOffset({required String point, bool considerFlip = false}) {
    if (!points.containsKey(point)) return null;

    final Point<int> p = points[point]!.pos;
    if (considerFlip) {
      return flippedPoint(p) - flippedOrigin;
    }

    return p - origin;
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
