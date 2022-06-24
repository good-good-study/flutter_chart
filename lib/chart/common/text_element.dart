import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/common/base_text_element.dart'
as common
    show BaseTextElement, MaxWidthStrategy, TextDirection, TextMeasurement;

/// Flutter implementation for text measurement and painter.
class TextElement implements common.BaseTextElement {
  static const ellipsis = '\u{2026}';

  @override
  final InlineSpan text;

  final double? textScaleFactor;

  var _painterReady = false;
  common.TextDirection _textDirection = common.TextDirection.ltr;

  @override
  TextAlign textAlign;

  int? _maxWidth;
  common.MaxWidthStrategy? _maxWidthStrategy;

  late TextPainter _textPainter;

  late common.TextMeasurement _measurement;

  TextElement(
    this.text, {
    this.textAlign = TextAlign.left,
    this.textScaleFactor,
  });

  @override
  set textDirection(common.TextDirection direction) {
    if (_textDirection == direction) {
      return;
    }
    _textDirection = direction;
    _painterReady = false;
  }

  @override
  common.TextDirection get textDirection => _textDirection;

  @override
  int? get maxWidth => _maxWidth;

  @override
  set maxWidth(int? value) {
    if (_maxWidth == value) {
      return;
    }
    _maxWidth = value;
    _painterReady = false;
  }

  @override
  common.MaxWidthStrategy? get maxWidthStrategy => _maxWidthStrategy;

  @override
  set maxWidthStrategy(common.MaxWidthStrategy? maxWidthStrategy) {
    if (_maxWidthStrategy == maxWidthStrategy) {
      return;
    }
    _maxWidthStrategy = maxWidthStrategy;
    _painterReady = false;
  }

  @override
  common.TextMeasurement get measurement {
    if (!_painterReady) {
      _refreshPainter();
    }

    return _measurement;
  }

  /// The estimated distance between where we asked to draw the text (top, left)
  /// and where it visually started (top + verticalFontShift, left).
  ///
  /// 10% of reported font height seems to be about right.
  int get verticalFontShift {
    if (!_painterReady) {
      _refreshPainter();
    }

    return (_textPainter.height * 0.1).ceil();
  }

  TextPainter? get textPainter {
    if (!_painterReady) {
      _refreshPainter();
    }
    return _textPainter;
  }

  /// Create text painter and measure based on current settings
  void _refreshPainter() {
    _textPainter = TextPainter(text: text)
      ..textDirection = TextDirection.ltr
      ..textAlign = textAlign
      ..ellipsis = maxWidthStrategy == common.MaxWidthStrategy.ellipsize
          ? ellipsis
          : null;

    if (textScaleFactor != null) {
      _textPainter.textScaleFactor = textScaleFactor!;
    }

    _textPainter.layout(maxWidth: maxWidth?.toDouble() ?? double.infinity);

    final baseline =
        _textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    // Estimating the actual draw height to 70% of measures size.
    //
    // The font reports a size larger than the drawn size, which makes it
    // difficult to shift the text around to get it to visually line up
    // vertically with other components.
    _measurement = common.TextMeasurement(
        horizontalSliceWidth: _textPainter.width,
        verticalSliceWidth: _textPainter.height * 0.7,
        baseline: baseline);

    _painterReady = true;
  }
}
