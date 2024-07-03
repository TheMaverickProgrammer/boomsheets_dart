import 'dart:io';
import 'dart:math';
import 'package:boomsheets_dart/src/anim.dart';
import 'package:boomsheets_dart/src/document.dart';
import 'package:boomsheets_dart/src/errors.dart';
import 'package:boomsheets_dart/src/keyframe.dart';
import 'package:boomsheets_dart/src/labeled_point.dart';
import 'package:boomsheets_dart/src/frametime.dart';
import 'package:yes_parser/yes_parser.dart';

typedef ParserErrorHandler = void Function(List<ErrorInfo> errors);

class DocumentReader {
  Document _doc = Document();
  String? _currAnim;
  Keyframe? _currKeyframe;
  ParserErrorHandler? _errorHandler;

  DocumentReader._();

  static Document fromString(String body, {ParserErrorHandler? onErrors}) {
    final DocumentReader reader = DocumentReader._();
    if (onErrors != null) {
      reader.handleErrors(onErrors);
    }

    YesParser.fromString(body).then(reader.process);
    return reader._doc;
  }

  static Future<Document> fromFile(File file,
      {ParserErrorHandler? onErrors}) async {
    final DocumentReader reader = DocumentReader._();
    if (onErrors != null) {
      reader.handleErrors(onErrors);
    }

    final p = YesParser.fromFile(file)..then(reader.process);
    await p.join();
    return reader._doc;
  }

  void handleErrors(final ParserErrorHandler onErrors) {
    _errorHandler = onErrors;
  }

  void process(List<Element> elements, List<ErrorInfo> errors) {
    _doc = Document();
    for (final el in elements) {
      switch (el.type) {
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

  void _processGlobal(Element el, List<ErrorInfo> errors) {
    switch (el.text) {
      case "frame_rate":
        _doc.frameRate = int.tryParse(el.args[0].val) ?? 60;
        break;
      case "image_path":
        _doc.imagePath = el.args[0].val;
        break;
    }
  }

  void _processStandard(Element el, List<ErrorInfo> errors) {
    switch (el.text) {
      case "anim" || "animation":
        _processAnim(el, errors);
        break;
      case "keyframe" || "frame":
        _processKeyframe(el, errors);
        break;
      case "empty":
        _processEmpty(el, errors);
      case "point":
        _processPoint(el, errors);
        break;
    }
  }

  void _processAnim(Element el, List<ErrorInfo> errors) {
    final String? state = el.getKeyValue("state", el.args[0].val);
    if (state == null) {
      errors.add(ErrorInfo.other(0, Errors.stateMissingLabel.message));
      return;
    }

    _doc.states[state] = Anim(state)..attrs = el.attrs;
    _currAnim = state;
  }

  void _processKeyframe(Element el, List<ErrorInfo> errors) {
    if (_currAnim == null) {
      errors.add(ErrorInfo.other(0, Errors.keyframeMissingAnimation.message));
      return;
    }

    String? dur = el.getKeyValue("duration", el.getKeyValue("dur"));
    if (dur == null) {
      errors.add(ErrorInfo.other(0, Errors.malformedEmpty.message));
      return;
    }

    if (dur.endsWith('f')) {
      dur = dur.substring(0, dur.length - 1);
    }

    final duration = Frametime(int.tryParse(dur) ?? 0);

    final Point<int> origin =
        Point(el.getKeyValueAsInt("originx"), el.getKeyValueAsInt("originy"));
    final Rectangle<int> rect = Rectangle(
        el.getKeyValueAsInt("x"),
        el.getKeyValueAsInt("y"),
        el.getKeyValueAsInt("w"),
        el.getKeyValueAsInt("h"));

    _currKeyframe = Keyframe(rect: rect, origin: origin, duration: duration)
      ..flipX = el.getKeyValueAsBool("flipx")
      ..flipY = el.getKeyValueAsBool("flipy")
      ..attrs = el.attrs;

    _doc.states[_currAnim!]?.keyframes.add(_currKeyframe!);
  }

  void _processEmpty(Element el, List<ErrorInfo> errors) {
    if (_currAnim == null) {
      errors.add(ErrorInfo.other(0, Errors.keyframeMissingAnimation.message));
      return;
    }

    String? dur = el.getKeyValue("duration", el.getKeyValue("dur"));
    if (dur == null) {
      errors.add(ErrorInfo.other(0, Errors.malformedEmpty.message));
      return;
    }

    if (dur.endsWith('f')) {
      dur = dur.substring(0, dur.length - 1);
    }

    final duration = Frametime(int.tryParse(dur) ?? 0);
    _doc.states[_currAnim!]?.keyframes.add(Keyframe.empty(duration: duration));
  }

  void _processPoint(Element el, List<ErrorInfo> errors) {
    final String? label = el.getKeyValue("label", el.args[0].val);
    if (label == null) {
      errors.add(ErrorInfo.other(0, Errors.pointMissingLabel.message));
      return;
    }

    if (_currKeyframe == null) {
      errors.add(ErrorInfo.other(0, Errors.pointMissingKeyframe.message));
      return;
    }

    _currKeyframe!.points.add(LabeledPoint(
        label: label,
        pos: Point(el.getKeyValueAsInt("x"), el.getKeyValueAsInt("y"))));
  }
}
