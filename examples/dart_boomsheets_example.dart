import 'dart:io';
import 'package:dart_boomsheets/dart_boomsheets.dart';

void main() async {
  Document doc = await DocumentReader.fromFile(
    File.fromUri(
      Uri.parse("examples/basic/test.anim"),
    ),
  );

  for (final MapEntry(:key, :value) in doc.states.entries) {
    for (final attr in value.attrs) {
      print(attr);
    }
    print("state=$key");
    for (final keyframe in value.keyframes) {
      for (final attr in keyframe.attrs) {
        print(attr);
      }
      print(keyframe);
    }
  }
}
