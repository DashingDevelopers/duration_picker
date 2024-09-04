import 'dart:math' as math;

import 'package:duration_picker/base_unit.dart';
import 'package:duration_picker/constants.dart';
import 'package:duration_picker/dial/dial.dart';
import 'package:flutter/material.dart';





/// A duration picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [Duration] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class DurationPickerDialog extends StatefulWidget {
final  Function? onChangeCallback;
  /// Creates a duration picker.
  ///
  /// [initialTime] must not be null.
  const DurationPickerDialog({
    Key? key,
    required this.initialTime,
    this.baseUnit = BaseUnit.minute,
    this.decoration,
    this.upperBound,
    this.lowerBound,
    this.title,
    this.screenScaling = 1.0,
    required this.onChangeCallback,
  }) : super(key: key);

  /// The duration initially selected when the dialog is shown.
  final Duration initialTime;
  final BaseUnit baseUnit;
  final BoxDecoration? decoration;
  final Duration? upperBound;
  final Duration? lowerBound;
  final String? title;
  final double screenScaling;

  @override
  DurationPickerDialogState createState() => DurationPickerDialogState();
}

class DurationPickerDialogState extends State<DurationPickerDialog> {
  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
  }

  Duration? get selectedDuration => _selectedDuration;
  Duration? _selectedDuration;

  late MaterialLocalizations localizations;

void _handleTimeChanged(Duration value) {
  setState(() {
    _selectedDuration = value;
    if (widget.onChangeCallback != null) {
      try {
        widget.onChangeCallback!(value);
      } catch (e) {
        print('Error in onChangeCallback: $e');
      }
    } else {
      print('onChangeCallback is null');
    }
  });
}

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, _selectedDuration);
  }

  @override
  Widget build(BuildContext context) {
    // print ('hi4');

    assert(debugCheckHasMediaQuery(context));
    final theme = Theme.of(context);
    final boxDecoration = widget.decoration ?? BoxDecoration(color: theme.dialogBackgroundColor);
    final Widget picker = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (widget.title != null) Text(widget.title!, style: theme.textTheme.headlineSmall),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              // child: Semantics(
              //   onIncrease: () {
              //     _handleTimeChanged(_selectedDuration! + const Duration(minutes: 1));
              //   },
              //   onDecrease: () {
              //     _handleTimeChanged(_selectedDuration! - const Duration(minutes: 1));
              //   },
              //   child: Dial(
              //     duration: _selectedDuration!,
              //     onChanged: _handleTimeChanged,
              //     baseUnit: widget.baseUnit,
              //   ),
              // ),
              child: Dial(
                duration: _selectedDuration!,
                onChanged: _handleTimeChanged,
                baseUnitDenomination: widget.baseUnit,
              ),
            ),
          ),
        ],
      ),
    );

    final Widget actions = ButtonBarTheme(
      data: ButtonBarTheme.of(context),
      child: ButtonBar(
        children: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: Text(localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: _handleOk,
            child: Text(localizations.okButtonLabel),
          ),
        ],
      ),
    );

    final dialog = Dialog(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final Widget pickerAndActions = DecoratedBox(
            decoration: boxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: picker,
                ), // picker grows and shrinks with the available space
                actions,
              ],
            ),
          );

          switch (orientation) {
            case Orientation.portrait:
              // print('portrait $_kDurationPickerWidthPortrait x $_kDurationPickerHeightPortrait screenScaling ${widget.screenScaling}');

              return SizedBox(
                width: kDurationPickerWidthPortrait * widget.screenScaling,
                height: kDurationPickerHeightPortrait * widget.screenScaling,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // if (widget.title != null) Text(widget.title!, style: theme.textTheme.headlineSmall),
                    Expanded(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
            case Orientation.landscape:
              // print('landscape $_kDurationPickerWidthLandscape x $_kDurationPickerHeightLandscape screenScaling ${widget.screenScaling}');
              return SizedBox(
                width: kDurationPickerWidthLandscape * widget.screenScaling,
                height: kDurationPickerHeightLandscape * widget.screenScaling,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Shows a dialog containing the duration picker.
///
/// The returned Future resolves to the duration selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// To show a dialog with [initialTime] equal to the current time:
///
/// ```dart
/// showDurationPicker(
///   initialTime: new Duration.now(),
///
///   context: context,
/// );
/// ```
Future<Duration?> showDurationPicker({
  required BuildContext context,
  required Duration initialTime,
  String? title,
  BaseUnit baseUnit = BaseUnit.minute,
  BoxDecoration? decoration,
  Duration? upperBound,
  Duration? lowerBound,
  double screenScaling = 1.0,
 Function? onChangeCallback,
}) async {
  return showDialog<Duration>(
    context: context,
    builder: (BuildContext context) => DurationPickerDialog(
        title: title,
        initialTime: initialTime,
        baseUnit: baseUnit,
        decoration: decoration,
        upperBound: upperBound,
        lowerBound: lowerBound,
        screenScaling: screenScaling,
        onChangeCallback: onChangeCallback),
  );
}

