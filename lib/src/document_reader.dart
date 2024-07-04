import 'dart:io';
import 'dart:math';
import 'package:boomsheets/src/anim.dart';
import 'package:boomsheets/src/document.dart';
import 'package:boomsheets/src/errors.dart';
import 'package:boomsheets/src/keyframe.dart';
import 'package:boomsheets/src/labeled_point.dart';
import 'package:boomsheets/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

/// [ParserErrorHandler] receives the errors and line numbers in [ErrorInfo].
typedef ParserErrorHandler = void Function(List<ErrorInfo> errors);

/// [DocumentReader] reads boomsheets documents and parses them using the
/// YES spec and generates [Keyframe], [Anim], and [Point] objects in the
/// resultant [Document].
///
/// All of the parsing and value-checking are performed for you. As such
/// those methods are private as well as the constructor for the reader.
///
/// In its place are two static public utility methods:
/// 1. [DocumentReader.fromString] reads a string of the document's contents.
/// The string expects the new-line characters to remain as line-terminators.
///
/// 2. [DocumentReader.fromFile] reads a [File] asynchronously.
///
/// Both methods return the final [Document]. To handle errors, pass in
/// a [ParserErrorHandler] callback function in both utility methods.
class DocumentReader {
  Document _doc = Document();
  String? _currAnim;
  Keyframe? _currKeyframe;
  ParserErrorHandler? _errorHandler;

  DocumentReader._();

  static Document fromString(String body, {ParserErrorHandler? onErrors}) {
    final DocumentReader reader = DocumentReader._();
    if (onErrors != null) {
      reader._handleErrors(onErrors);
    }

    YesParser.fromString(body).onComplete(reader._process);
    return reader._doc;
  }

  static Future<Document> fromFile(File file,
      {ParserErrorHandler? onErrors}) async {
    final DocumentReader reader = DocumentReader._();
    if (onErrors != null) {
      reader._handleErrors(onErrors);
    }

    final p = YesParser.fromFile(file)..onComplete(reader._process);
    await p.join();
    return reader._doc;
  }

  void _handleErrors(final ParserErrorHandler onErrors) {
    _errorHandler = onErrors;
  }

  void _process(List<ElementInfo> elements, List<ErrorInfo> errors) {
    _doc = Document();
    for (final el in elements) {
      switch (el.element.type) {
        case ElementType.global:
          _processGlobal(el, errors);
          continue;
        case ElementType.standard:
          _processStandard(el, errors);
          continue;
        case _:
        // fall-through
      }
    }
    _errorHandler?.call(errors);
  }

  void _processGlobal(ElementInfo info, List<ErrorInfo> errors) {
    final String name = info.element.text;

    if (info.element.args.isEmpty) {
      errors.add(ErrorInfo.other(info.line, "$name expected a value"));
      return;
    }
    switch (name) {
      case "frame_rate":
        _doc.frameRate = int.tryParse(info.element.args[0].val) ?? 60;
        break;
      case "image_path":
        _doc.imagePath = info.element.args[0].val;
        break;
    }
  }

  void _processStandard(ElementInfo info, List<ErrorInfo> errors) {
    final String keyword = info.element.text;
    switch (keyword) {
      case "anim" || "animation":
        _processAnim(info, errors);
        break;
      case "keyframe" || "frame":
        _processKeyframe(info, errors);
        break;
      case "empty":
        _processEmpty(info, errors);
      case "point":
        _processPoint(info, errors);
        break;
      default:
        errors.add(ErrorInfo.other(info.line, "Unexpected keyword $keyword"));
    }
  }

  void _processAnim(ElementInfo info, List<ErrorInfo> errors) {
    final Standard keyword = info.element as Standard;

    if (keyword.args.isEmpty) {
      errors.add(ErrorInfo.other(info.line, Errors.stateMissingLabel.message));
      return;
    }

    final String? state = keyword.getKeyValue("state", keyword.args[0].val);
    if (state == null) {
      errors.add(ErrorInfo.other(info.line, Errors.stateMissingLabel.message));
      return;
    }

    _doc.states[state] = Anim(state)..attrs = keyword.attrs;
    _currAnim = state;
  }

  void _processKeyframe(ElementInfo info, List<ErrorInfo> errors) {
    final Standard keyword = info.element as Standard;

    if (_currAnim == null) {
      errors.add(
          ErrorInfo.other(info.line, Errors.keyframeMissingAnimation.message));
      return;
    }

    if (keyword.args.isEmpty) {
      errors.add(ErrorInfo.other(info.line, Errors.malformedKeyframe.message));
      return;
    }

    String? dur = keyword.getKeyValue(
      "duration",
      keyword.getKeyValue("dur", keyword.args[0].val),
    );
    if (dur == null) {
      errors.add(ErrorInfo.other(info.line, Errors.malformedEmpty.message));
      return;
    }

    if (dur.endsWith('f')) {
      dur = dur.substring(0, dur.length - 1);
    }

    final duration = Frametime(int.tryParse(dur) ?? 0);

    final Point<int> origin = Point(
      keyword.getKeyValueAsInt("originx"),
      keyword.getKeyValueAsInt("originy"),
    );
    final Rectangle<int> rect = Rectangle(
        keyword.getKeyValueAsInt("x"),
        keyword.getKeyValueAsInt("y"),
        keyword.getKeyValueAsInt("w"),
        keyword.getKeyValueAsInt("h"));

    _currKeyframe = Keyframe(rect: rect, origin: origin, duration: duration)
      ..flipX = keyword.getKeyValueAsBool("flipx")
      ..flipY = keyword.getKeyValueAsBool("flipy")
      ..attrs = keyword.attrs;

    _doc.states[_currAnim!]?.keyframes.add(_currKeyframe!);
  }

  void _processEmpty(ElementInfo info, List<ErrorInfo> errors) {
    if (_currAnim == null) {
      errors.add(
          ErrorInfo.other(info.line, Errors.keyframeMissingAnimation.message));
      return;
    }

    final Standard empty = info.element as Standard;
    if (empty.args.isEmpty) {
      errors.add(ErrorInfo.other(info.line, Errors.malformedEmpty.message));
      return;
    }
    String? dur = empty.getKeyValue(
        "duration", empty.getKeyValue("dur", empty.args[0].val));
    if (dur == null) {
      errors.add(ErrorInfo.other(info.line, Errors.malformedEmpty.message));
      return;
    }

    if (dur.endsWith('f')) {
      dur = dur.substring(0, dur.length - 1);
    }

    final duration = Frametime(int.tryParse(dur) ?? 0);
    _doc.states[_currAnim!]?.keyframes.add(Keyframe.empty(duration: duration));
  }

  void _processPoint(ElementInfo info, List<ErrorInfo> errors) {
    final Standard point = info.element as Standard;

    if (point.args.isEmpty) {
      errors.add(ErrorInfo.other(0, Errors.pointMissingLabel.message));
      return;
    }

    final String? label = point.getKeyValue("label", point.args[0].val);
    if (label == null) {
      errors.add(ErrorInfo.other(0, Errors.pointMissingLabel.message));
      return;
    }

    if (_currKeyframe == null) {
      errors.add(ErrorInfo.other(0, Errors.pointMissingKeyframe.message));
      return;
    }

    _currKeyframe!.points.add(
      LabeledPoint(
        label: label,
        pos: Point(
          point.getKeyValueAsInt("x"),
          point.getKeyValueAsInt("y"),
        ),
      ),
    );
  }
}
