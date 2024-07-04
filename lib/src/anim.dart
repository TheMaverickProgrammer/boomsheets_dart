import 'package:boomsheets/src/keyframe.dart';
import 'package:boomsheets/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

class Anim {
  Frametime? _totalDuration;
  List<Attribute> attrs;
  List<Keyframe> keyframes;
  final String name;

  /// Creates state [Anim] called [name] with [keyframes] and [attributes].
  Anim(this.name, {List<Keyframe>? keyframes, List<Attribute>? attributes})
      : keyframes = keyframes ?? [],
        attrs = attributes ?? [];

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
