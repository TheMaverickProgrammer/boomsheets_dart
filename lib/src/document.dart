import 'package:boomsheets/src/anim.dart';

class Document {
  final Map<String, Anim> states = {};
  String path = "";
  String imagePath = "";
  int frameRate = 60; // in Hz
}
