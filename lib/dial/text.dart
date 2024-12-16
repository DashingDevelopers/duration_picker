import 'package:duration_picker/base_unit.dart';
import 'package:duration_picker/localization/localization.dart';
import 'package:flutter/material.dart';

/// Use [DialPainter] to style the durationPicker to your style.
class TextHelper {
  const TextHelper({
    required this.context,

    // required this.labels,

    // required this.backgroundColor,
    // required this.accentColor,
    // required this.theta, //Measured angle in radians
    // required this.textDirection,
    required this.higherOrderUnitValue,
    required this.baseUnitValue,
    required this.baseUnitDenomination,
  });

  // final List<TextPainter> labels;
  // final Color? backgroundColor;
  // final Color accentColor;
  // final double theta;
  // final TextDirection textDirection;
  //
  final BuildContext context;

  //
  final int higherOrderUnitValue;
  final int baseUnitValue;
  final BaseUnit baseUnitDenomination;

  // Get the appropriate base unit string
  String getBaseUnitString() {
    final localization = DurationPickerLocalizations.of(context);

    switch (baseUnitDenomination) {
      case BaseUnit.millisecond:
        return localization.baseUnitMillisecond;
      case BaseUnit.second:
        return localization.baseUnitSecond;
      case BaseUnit.minute:
        return localization.baseUnitMinute;
      case BaseUnit.hour:
        return localization.baseUnitHour;
    }
  }

  // Get the appropriate secondary unit string
  String getHigherOrderUnitString() {
    final localization = DurationPickerLocalizations.of(context);

    switch (baseUnitDenomination) {
      case BaseUnit.millisecond:
        return localization.secondaryUnitMillisecond;
      case BaseUnit.second:
        return localization.secondaryUnitSecond;
      case BaseUnit.minute:
        return localization.secondaryUnitMinute;
      case BaseUnit.hour:
        return localization.secondaryUnitHour;
    }
  }

  // Draw the Text in the center of the circle which displays the duration string
  get higherOrderUnits => higherOrder(higherOrderUnitValue);

  String higherOrder(int houv) {
    return (houv == 0) ? '' : '${houv}${getHigherOrderUnitString()} ';
  }

  get baseUnits {
    return base(baseUnitValue);
  }

  String base(int buv) => '${buv.toString().padLeft(2,' ')}${getBaseUnitString()}';

  String get durationString => '$higherOrderUnits$baseUnits';

  String getDurationString(houv,bov) {
    return '${higherOrder(houv)}${base(bov)}';
  }


}

/// The [DurationPicker] widget.
