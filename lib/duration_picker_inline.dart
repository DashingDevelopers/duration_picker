import 'package:duration_picker/base_unit.dart';
import 'package:duration_picker/constants.dart';
import 'package:duration_picker/dial/dial.dart';
import 'package:flutter/material.dart';

/// The [DurationPicker] widget.
class DurationPicker extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration> onChange;
  final BaseUnit baseUnit;
  final Duration? upperBound;
  final Duration? lowerBound;
  @Deprecated('This value was never used')
  final double? snapToMins;

  final double? width;
  final double? height;

  const DurationPicker({
    Key? key,
    this.duration = Duration.zero,
    required this.onChange,
    this.baseUnit = BaseUnit.minute,
    this.upperBound,
    this.lowerBound,
    this.width,
    this.height,
    @Deprecated('This value was never used') this.snapToMins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('DurationPicker build');
    return SizedBox(
      width: width ?? kDurationPickerWidthPortrait / 1.5,
      height: height ?? kDurationPickerHeightPortrait / 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Dial(
              duration: duration,
              onChanged: onChange,
              baseUnitDenomination: baseUnit,
              upperBound: upperBound,
              lowerBound: lowerBound,
              title: 'Duration',
            ),
          ),
        ],
      ),
    );
  }
}
