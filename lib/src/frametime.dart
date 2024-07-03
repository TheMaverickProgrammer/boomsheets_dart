extension type Frametime(int count) {
  static int framesPerSecond = 60;
  static Frametime zero = Frametime(0);

  Frametime.fromDuration(Duration from)
      : count = ((from.inMilliseconds / 1000) * framesPerSecond).toInt();

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

class Tickrate {
  final int units;
  final int delay;

  const Tickrate(this.units, this.delay)
      : assert(delay >= 0, "Delay must be a non-negative value.");

  factory Tickrate.fromPercentage(double percent) {
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
