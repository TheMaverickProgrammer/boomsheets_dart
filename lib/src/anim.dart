import 'package:boomsheets_dart/src/keyframe.dart';
import 'package:boomsheets_dart/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

class Anim {
  Frametime? _totalDuration;
  List<Attribute> attrs = [];
  List<Keyframe> keyframes = [];
  final String name;
  Anim(this.name);

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
