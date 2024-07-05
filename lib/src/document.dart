import 'package:boomsheets/src/anim.dart';

/// [Document] represents a fully-parsed `.anim` file.
///
/// It has a hash map of [states] which can be used to lookup
/// [Anim] objects by their [Anim.name].
///
/// The global values `!frame_rate` and `!image_path` are stored in
/// [imagePath] and [frameRate] respectively.
class Document {
  final Map<String, Anim> states = {};
  String imagePath = "";
  int frameRate = 60; // in Hz
}
