import 'dart:io';
import 'package:boomsheets_dart/lib.dart';
import 'package:yes_parser/yes_parser.dart';

void main() async {
  Document doc = await DocumentReader.fromFile(
    File.fromUri(
      Uri.parse("examples/test.anim"),
    ),
    onErrors: printErrors,
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

void printErrors(List<ErrorInfo> errors) {
  for (ErrorInfo info in errors) {
    // We are not interested in empty line errors
    if (info.type == ErrorType.eolNoData) continue;

    print(">>>> Error on line ${info.line}: ${info.message}");
  }
}
