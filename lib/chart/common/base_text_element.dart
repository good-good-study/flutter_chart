import 'package:flutter/material.dart';

abstract class BaseTextElement {
  /// The max width of this [BaseTextElement] during measure and layout.
  ///
  /// If the text exceeds maxWidth, the [maxWidthStrategy] is used.
  int? get maxWidth;

  set maxWidth(int? value);

  /// The strategy to use if this [BaseTextElement] exceeds the [maxWidth].
  MaxWidthStrategy? get maxWidthStrategy;

  set maxWidthStrategy(MaxWidthStrategy? maxWidthStrategy);

  // The text of this [TextElement].
  InlineSpan get text;

  /// The [TextMeasurement] of this [BaseTextElement] as an approximate of what
  /// is actually printed.
  ///
  /// Will return the [maxWidth] if set and the actual text width is larger.
  TextMeasurement get measurement;

  /// The direction to render the text relative to the coordinate.
  TextDirection get textDirection;

  set textDirection(TextDirection direction);

  TextAlign get textAlign;

  /// Return true if settings are all the same.
  ///
  /// Purposely excludes measurement because the measurement will request the
  /// native [BaseTextElement] to layout, which is expensive. We want to avoid the
  /// layout by comparing with another [BaseTextElement] to see if they have the
  /// same settings.
  static bool elementSettingsSame(BaseTextElement a, BaseTextElement b) {
    return a.maxWidth == b.maxWidth &&
        a.maxWidthStrategy == b.maxWidthStrategy &&
        a.text == b.text &&
        a.textDirection == b.textDirection;
  }
}

enum TextDirection {
  ltr,
  rtl,
  center,
}

/// The strategy to use if a [BaseTextElement] exceeds the [maxWidth].
enum MaxWidthStrategy {
  truncate,
  ellipsize,
}

/// A measurement result for rendering text.
class TextMeasurement {
  /// Rendered width of the text.
  final double horizontalSliceWidth;

  /// Vertical slice is likely based off the rendered text.
  ///
  /// This means that 'mo' and 'My' will have different heights so do not use
  /// this for centering vertical text.
  final double verticalSliceWidth;

  /// Baseline of the text for text vertical alignment.
  final double? baseline;

  TextMeasurement({
    required this.horizontalSliceWidth,
    required this.verticalSliceWidth,
    this.baseline,
  });
}
