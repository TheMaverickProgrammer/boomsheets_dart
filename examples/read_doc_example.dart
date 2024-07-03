import 'dart:io';
import 'package:boomsheets_dart/lib.dart';

void main() async {
  Document doc = await DocumentReader.fromFile(
    File.fromUri(
      Uri.parse("examples/test.anim"),
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
