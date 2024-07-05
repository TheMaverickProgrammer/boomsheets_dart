/// An extension over [int] storing the value in [count].
///
/// [Frametime] units are for frame-perfect or even pixel-perfect
/// applications. They cannot be fractional. For frames over a delay,
/// see [Tickrate].
///
/// This extension overrides the basic addition, subtraction, and comparison
/// operators. Shorthand [inc] and [dec] functions are provided for one tick.
///
/// Conversions from [Duration] are lossy because only full frames are counted.
extension type const Frametime(int count) {
  /// Mutable [framesPerSecond] can be changed. Represents `hz` or frame rate.
  static int framesPerSecond = 60;

  /// Shorthand for a zero value.
  static const Frametime zero = Frametime(0);

  /// Lossy convert [Duration] to [Frametime]. [count] = `(milli/1000)*hz`.
  Frametime.fromDuration(Duration from)
      : count = ((from.inMilliseconds / 1000) * framesPerSecond).toInt();

  /// Convert [Frametime] to [Duration] up to milliseconds precision.
  Duration toDuration() {
    return Duration(
        seconds: count ~/ framesPerSecond,
        milliseconds: count % framesPerSecond);
  }

  Frametime inc() {
    return Frametime(count + 1);
  }

  Frametime dec() {
    return Frametime(count - 1);
  }

  Frametime operator +(Frametime val) {
    return Frametime(count + val.count);
  }

  Frametime operator -(Frametime val) {
    return Frametime(count - val.count);
  }

  bool operator <(Frametime other) {
    return count < other.count;
  }

  bool operator <=(Frametime other) {
    return count <= other.count;
  }

  bool operator >(Frametime other) {
    return count > other.count;
  }

  bool operator >=(Frametime other) {
    return count >= other.count;
  }
}

/// [Tickrate] provides fractional [Frametime] values over time via [digest].
///
/// [Frametime] values are whole integers and represent frame-perfect or even
/// pixel-perfect quanities. Because of this, representing anything less than
/// 1 fixed unit is impossible. [Tickrate] takes in a [units] and [delay] field
/// and represent the expression "every ([delay]-1) frames, increase [units]".
///
/// ```dart
///   // Every 5 frames move 2 pixels, or in other words:
///   // After 4 frames, the next frame yields an additional 2 pixels.
///   frame = frame.inc();
///   final ticker = Tickrate(2, 4);
///   playerXY += Vector2(ticker.digest(frame), playerXY.y);
/// ```
class Tickrate {
  final int units;
  final int delay;

  const Tickrate(this.units, this.delay)
      : assert(delay >= 0, "Delay must be a non-negative value.");

  /// Creates a lossy [Tickrate] using a factor proportional to the [percent].
  ///
  /// Use on frame-perfect animations that need a concept of fractional speed.
  factory Tickrate.fromPercentage(double percent) {
    percent /= 100.0;

    final double r = percent.remainder(1.0);
    if (r == 0) {
      return Tickrate(percent.toInt(), 0);
    }

    final double d = 1.0 / r;
    return Tickrate((d * percent).toInt(), (d - 1.0).toInt());
  }

  Frametime digest(Frametime elapsed) {
    return Frametime((elapsed.count / (delay + 1)).floor() * units);
  }

  double fractional() {
    return units / (delay + 1);
  }
}
