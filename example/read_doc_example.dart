import 'dart:io';
import 'package:boomsheets/boomsheets.dart';
import 'package:yes_parser/yes_parser.dart';

void main() async {
  final Document doc = await DocumentReader.fromFile(
    File.fromUri(
      Uri.parse("example/test.anim"),
    ),
    onErrors: printErrors,
  );

  // Print every Anim state in the doc
  for (final MapEntry(:key, :value) in doc.states.entries) {
    // Anim states can have attributes
    for (final attr in value.attrs) {
      print(attr);
    }

    // Print the state name.
    print("state=$key");

    // Followed by all the keyframes.
    for (final keyframe in value.keyframes) {
      // Keyframes can have attributes.
      for (final attr in keyframe.attrs) {
        print(attr);
      }
      // Print the key frame
      print(keyframe);

      // Keyframes have zero or more point data
      for (final iter in keyframe.points.entries) {
        print(iter.value);
      }
    }
  }
}

void printErrors(List<ErrorInfo> errors) {
  for (ErrorInfo info in errors) {
    // We are not interested in empty line errors
    if (info.type == ErrorType.eolNoData) continue;

    print(">>>> Error on line ${info.line}: ${info.message}");
  }
}
