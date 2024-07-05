import 'dart:math';

/// Point<int> [pos] with a String [label].
class LabeledPoint {
  String label;
  Point<int> pos;
  LabeledPoint({required this.label, required this.pos});

  @override
  String toString() => "point={$label, x=${pos.x}, y=${pos.y}}";
}
