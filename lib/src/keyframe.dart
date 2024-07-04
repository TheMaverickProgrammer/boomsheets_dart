import 'dart:math';
import 'package:boomsheets_dart/src/labeled_point.dart';
import 'package:boomsheets_dart/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

extension PointZero on Point<int> {
  static Point<int> zero() => Point(0, 0);
}

class Keyframe {
  List<Attribute> attrs = [];
  Rectangle<int> rect;
  Point<int> origin;
  List<LabeledPoint> points = [];
  bool flipX;
  bool flipY;
  Frametime duration;

  final bool isEmpty;

  Point<double> get canonicalOrigin {
    double w = 0;
    double h = 0;

    if (rect.width != 0) {
      w = origin.x / rect.width;
    }

    if (rect.height != 0) {
      h = origin.y / rect.height;
    }

    return Point<double>(w, h);
  }

  Keyframe(
      {required this.rect,
      required this.origin,
      required this.duration,
      this.flipX = false,
      this.flipY = false})
      : isEmpty = false;

  Keyframe.empty({required this.duration})
      : isEmpty = true,
        rect = Rectangle.fromPoints(PointZero.zero(), PointZero.zero()),
        origin = PointZero.zero(),
        flipX = false,
        flipY = false;

  @override
  String toString() {
    if (isEmpty) {
      return 'empty $duration';
    }

    return '{$duration, $rect, $origin, $flipX, $flipY}';
  }
}
