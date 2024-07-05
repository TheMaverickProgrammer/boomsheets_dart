import 'package:boomsheets/src/keyframe.dart';
import 'package:boomsheets/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

/// [Anim] represents a single animation state with a [name].
///
/// [totalDuration] calculates the total number of frames as [Frametime] units.

class Anim {
  Frametime? _totalDuration;
  List<Attribute> attrs;
  List<Keyframe> keyframes;
  final String name;

  /// Creates state [Anim] called [name] with provided data.
  Anim(
    this.name, {
    List<Keyframe>? keyframes,
    List<Attribute>? attributes,
  })  : keyframes = keyframes ?? [],
        attrs = attributes ?? [];

  // Calculate and caches the total duration of this anim state.
  Frametime get totalDuration {
    if (_totalDuration != null) return _totalDuration!;

    Frametime t = Frametime(0);
    for (final kf in keyframes) {
      t += kf.duration;
    }

    _totalDuration = t;
    return _totalDuration!;
  }
}
