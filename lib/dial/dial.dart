import 'dart:io';
import 'dart:math' as math;

import 'package:duration_picker/base_unit.dart';
import 'package:duration_picker/constants.dart';
import 'package:duration_picker/dial/painter.dart';
import 'package:duration_picker/dial/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Use [DialPainter] to style the durationPicker to your style.

class Dial extends StatefulWidget {
  final Function? onChangeCallback;

  final Color? backgroundColor;

  final Color? accentColor;

  const Dial(
      {required this.duration,
      required this.onChanged,
      this.baseUnitDenomination = BaseUnit.minute,
      this.upperBound,
      this.lowerBound,
      this.onChangeCallback,
      this.backgroundColor,
      this.accentColor,
      this.themeOverride,
      required this.title});

  final Duration duration;
  final ValueChanged<Duration> onChanged;
  final BaseUnit baseUnitDenomination;
  final Duration? upperBound;
  final Duration? lowerBound;
  final String title;
  final ThemeData? themeOverride;

  @override
  DialState createState() => DialState();
}

class DialState extends State<Dial> with SingleTickerProviderStateMixin {
  late final double? _upperBoundAngle;
  late final double? _lowerBoundAngel;

  @override
  void initState() {
    super.initState();
    _thetaController = AnimationController(
      duration: kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(
      begin: _getThetaForDuration(widget.duration, widget.baseUnitDenomination),
      end: 0,
      //end: _getThetaForDuration(widget.duration, widget.baseUnit),
    );
    _theta = _thetaTween.animate(
      CurvedAnimation(parent: _thetaController, curve: Curves.fastOutSlowIn),
    )..addListener(() => setState(() {}));
    _thetaController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _higherOrderUnitValue = _higherOrderUnitHand();
        _baseUnitValue = _baseUnitHand();
        setState(() {});
      }
    });
    _turningAngle = kPiByTwo - _turningAngleFactor(null) * kTwoPi;
    _higherOrderUnitValue = _higherOrderUnitHand();
    _baseUnitValue = _baseUnitHand();

    _upperBoundAngle = widget.upperBound != null ? kPiByTwo - _turningAngleFactor(widget.upperBound) * kTwoPi : null;
    _lowerBoundAngel = widget.lowerBound != null ? kPiByTwo - _turningAngleFactor(widget.lowerBound) * kTwoPi : null;
  }

  late ThemeData themeData;
  MaterialLocalizations? localizations;
  MediaQueryData? media;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void dispose() {
    _thetaController.dispose();
    super.dispose();
  }

  late Tween<double> _thetaTween;
  late Animation<double> _theta;
  late AnimationController _thetaController;

  int _higherOrderUnitValue = 0;
  bool _dragging = false;
  int _baseUnitValue = 0;
  double _turningAngle = 0.0;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final currentTheta = _theta.value;
    var beginTheta = _nearest(targetTheta, currentTheta, currentTheta + kTwoPi);
    beginTheta = _nearest(targetTheta, beginTheta, currentTheta - kTwoPi);
    _thetaTween
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController
      ..value = 0.0
      ..forward();
  }

  double _getThetaForDuration(Duration duration, BaseUnit baseUnit) {
    final int baseUnits = baseUnit.getDurationInBaseUnits(duration);
    final int baseToSecondaryFactor = baseUnit.getBaseUnitToSecondaryUnitFactor();

    return (kPiByTwo - (baseUnits % baseToSecondaryFactor) / baseToSecondaryFactor.toDouble() * kTwoPi) % kTwoPi;
  }

  double _turningAngleFactor(Duration? duration) {
    return widget.baseUnitDenomination.getDurationInBaseUnits(
          duration ?? widget.duration,
        ) /
        widget.baseUnitDenomination.getBaseUnitToSecondaryUnitFactor();
  }

  Duration _getTimeForTheta(double theta) {
    return _angleToDuration(_turningAngle);
  }

  Duration _notifyOnChangedIfNeeded() {
    // if (widget.onChangeCallback != null) widget.onChangeCallback!();
    _higherOrderUnitValue = _higherOrderUnitHand();
    _baseUnitValue = _baseUnitHand();
    final d = _angleToDuration(_turningAngle);
    widget.onChanged(d);

    return d;
  }

  void _updateThetaForPan() {
    setState(() {
      final offset = _position! - _center!;
      final angle = (math.atan2(offset.dx, offset.dy) - kPiByTwo) % kTwoPi;

      // Stop accidental abrupt pans from making the dial seem like it starts from 1h.
      // (happens when wanting to pan from 0 clockwise, but when doing so quickly, one actually pans from before 0 (e.g. setting the duration to 59mins, and then crossing 0, which would then mean 1h 1min).
      if (angle >= kCircleTop &&
          _theta.value <= kCircleTop &&
          _theta.value >= 0.1 && // to allow the radians sign change at 15mins.
          _higherOrderUnitValue == 0) return;

      _thetaTween
        ..begin = angle
        ..end = angle;
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);

    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final oldTheta = _theta.value;
    _position = _position! + details.delta;
    // _position! += details.delta;
    _updateThetaForPan();
    final newTheta = _theta.value;

    _updateTurningAngle(oldTheta, newTheta);
    _notifyOnChangedIfNeeded();
  }

  int _higherOrderUnitHand() {
    return widget.baseUnitDenomination.higherOrderUnitHand(widget.duration);
  }

  int _baseUnitHand() {
    // Result is in [0; num base units in secondary unit - 1], even if overall time is >= 1 secondary unit
    return widget.baseUnitDenomination.baseUnitHand(widget.duration);
  }

  Duration _angleToDuration(double angle) {
    return _baseUnitToDuration(_angleToBaseUnit(angle));
  }

  Duration _baseUnitToDuration(double baseUnitValue) {
    final int unitFactor = widget.baseUnitDenomination.getBaseUnitToSecondaryUnitFactor();

    switch (widget.baseUnitDenomination) {
      case BaseUnit.millisecond:
        return Duration(
          seconds: baseUnitValue ~/ unitFactor,
          milliseconds: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.second:
        return Duration(
          minutes: baseUnitValue ~/ unitFactor,
          seconds: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.minute:
        return Duration(
          hours: baseUnitValue ~/ unitFactor,
          minutes: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.hour:
        return Duration(
          days: baseUnitValue ~/ unitFactor,
          hours: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
    }
  }

  String _durationToBaseUnitString(Duration duration) {
    switch (widget.baseUnitDenomination) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds.toString();
      case BaseUnit.second:
        return duration.inSeconds.toString();
      case BaseUnit.minute:
        return duration.inMinutes.toString();
      case BaseUnit.hour:
        return duration.inHours.toString();
    }
  }

  double _angleToBaseUnit(double angle) {
    // Coordinate transformation from mathematical COS to dial COS
    final dialAngle = kPiByTwo - angle;

    // Turn dial angle into minutes, may go beyond 60 minutes (multiple turns)
    return dialAngle / kTwoPi * widget.baseUnitDenomination.getBaseUnitToSecondaryUnitFactor();
  }

  void _updateTurningAngle(double oldTheta, double newTheta) {
    // Register any angle by which the user has turned the dial.
    //
    // The resulting turning angle fully captures the state of the dial,
    // including multiple turns (= full hours). The [_turningAngle] is in
    // mathematical coordinate system, i.e. 3-o-clock position being zero, and
    // increasing counter clock wise.

    // From positive to negative (in mathematical COS)
    if (newTheta > 1.5 * math.pi && oldTheta < 0.5 * math.pi) {
      _turningAngle = _turningAngle - ((kTwoPi - newTheta) + oldTheta);
    }
    // From negative to positive (in mathematical COS)
    else if (newTheta < 0.5 * math.pi && oldTheta > 1.5 * math.pi) {
      _turningAngle = _turningAngle + ((kTwoPi - oldTheta) + newTheta);
    } else {
      _turningAngle = _turningAngle + (newTheta - oldTheta);
    }

    if (_upperBoundAngle != null && _turningAngle < _upperBoundAngle!) {
      _turningAngle = _upperBoundAngle!;
    } else if (_lowerBoundAngel != null && _turningAngle > _lowerBoundAngel!) {
      _turningAngle = _lowerBoundAngel!;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    _animateTo(_getThetaForDuration(widget.duration, widget.baseUnitDenomination));
  }

  void _handleTapUp(TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();

    _animateTo(
      _getThetaForDuration(_getTimeForTheta(_theta.value), widget.baseUnitDenomination),
    );
    _dragging = false;
    _position = null;
    _center = null;
  }

  //PR font scaling, but small fonts need  a different offset.
  List<TextPainter> _buildBaseUnitLabels(TextTheme textTheme, Size size) {
    final style =
        textTheme.titleMedium!.copyWith(fontSize: size.shortestSide * 0.05 * MediaQuery.of(context).textScaleFactor);
    // fontSize: size.shortestSide * 0.07
    var baseUnitMarkerValues = <Duration>[];

    switch (widget.baseUnitDenomination) {
      case BaseUnit.millisecond:
        const int interval = 100;
        const int factor = Duration.millisecondsPerSecond;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(milliseconds: index * interval),
        );
        break;
      case BaseUnit.second:
        const int interval = 5;
        const int factor = Duration.secondsPerMinute;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(seconds: index * interval),
        );
        break;
      case BaseUnit.minute:
        const int interval = 5;
        const int factor = Duration.minutesPerHour;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(minutes: index * interval),
        );
        break;
      case BaseUnit.hour:
        const int interval = 3;
        const int factor = Duration.hoursPerDay;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(length, (index) => Duration(hours: index * interval));
        break;
    }

    final labels = <TextPainter>[];
    for (final duration in baseUnitMarkerValues) {
      final painter = TextPainter(
        text: TextSpan(style: style, text: _durationToBaseUnitString(duration)),
        textDirection: TextDirection.ltr,
      )..layout();
      labels.add(painter);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor = widget.backgroundColor;
    final accentColor = widget.accentColor ?? themeData.colorScheme.secondary;

    if (backgroundColor == null) {
      switch (themeData.brightness) {
        case Brightness.light:
          backgroundColor = Colors.grey[200];
          break;
        case Brightness.dark:
          backgroundColor = themeData.colorScheme.surface;
          break;
      }
    }

    final theme = widget.themeOverride ?? Theme.of(context);

    // int? selectedDialValue;
    _higherOrderUnitValue = _higherOrderUnitHand();
    _baseUnitValue = _baseUnitHand();

    final TextHelper textHelper = TextHelper(
      context: context,
      higherOrderUnitValue: _higherOrderUnitValue,
      baseUnitValue: _baseUnitValue,
      baseUnitDenomination: widget.baseUnitDenomination,
    );

    return GestureDetector(
      excludeFromSemantics: true,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapUp: _handleTapUp,
      // PR for labels to scale,  constraints are acquired for build base unit labels
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        final incValue = widget.duration + widget.baseUnitDenomination.singleUnitDuration;

        late String incTalk;
        final canIncrease = (widget.upperBound == null || incValue < widget.upperBound!);

        if (canIncrease) {
          final houv = widget.baseUnitDenomination.higherOrderUnitHand(incValue);
          final buv = widget.baseUnitDenomination.baseUnitHand(incValue);
          incTalk = textHelper.getDurationString(houv, buv);
        } else {
          final houv = widget.baseUnitDenomination.higherOrderUnitHand(widget.upperBound!);
          final buv = widget.baseUnitDenomination.baseUnitHand(widget.upperBound!);
          incTalk = 'Cannot increase beyond ${textHelper.getDurationString(houv, buv)}';
        }

        final decValue = widget.duration - widget.baseUnitDenomination.singleUnitDuration;
        final canDecrease = widget.lowerBound == null || decValue > widget.lowerBound!;
        late String decTalk;

        if (canDecrease) {
          final houv = widget.baseUnitDenomination.higherOrderUnitHand(decValue);
          final bov = widget.baseUnitDenomination.baseUnitHand(decValue);
          decTalk = textHelper.getDurationString(houv, bov);
        } else {
          final houv = widget.baseUnitDenomination.higherOrderUnitHand(widget.lowerBound!);
          final bov = widget.baseUnitDenomination.baseUnitHand(widget.lowerBound!);
          decTalk = 'Cannot decrease beyond ${textHelper.getDurationString(houv, bov)}';
        }

        // print('widget.title: ${widget.title} incTalk: $incTalk, decTalk: $decTalk');

        //TODO check if this is the correct strategy for MacOs,Linux & Windows
        bool useAnnounceStrategy = !kIsWeb &&
            Platform
                .isIOS; // || Platform.isMacOS; MacOS doesn't seem to care about sliders in general // || Platform.isMacOS; MacOS doesn't seem to care about sliders in general
        bool useValueStrategy = !useAnnounceStrategy;

        late String? label;
        late String? value;
        if (useValueStrategy) {
          label =
              '${widget.title}'; //Label is announced upon each change after the altered value, then the word slider: "{newValue} {label} slider"
          value = textHelper
              .durationString; // value is announced on widget first build followed by label : "{value} {label} slider"
        } else {
          label =
              '${widget.title} ${textHelper.durationString}'; // label is announced on widget first build : "{label}"
          value =
              null; //on each change the SemanticSercice.announce is used to announce the change (currently just the new value) : "{newValue}"
        }

        return Semantics(
            liveRegion: false,
            label: label,
            value: value,
            increasedValue: useValueStrategy ? incTalk : null,
            decreasedValue: useValueStrategy ? decTalk : null,
            onIncrease: () {
              if (canIncrease) {
                widget.onChanged(incValue);
                if (useAnnounceStrategy) SemanticsService.announce(incTalk, Directionality.of(context));
              }
            },
            onDecrease: () {
              if (canDecrease) widget.onChanged(decValue);
              {
                widget.onChanged(decValue);
                if (useAnnounceStrategy) SemanticsService.announce(decTalk, Directionality.of(context));
              }
            },
            child: Semantics(
              excludeSemantics: true,
              child: CustomPaint(
                painter: DialPainter(
                  baseUnitMultiplier: _higherOrderUnitValue,
                  baseUnitHand: _baseUnitValue,
                  baseUnit: widget.baseUnitDenomination,
                  context: context,
                  // selectedValue: selectedDialValue,
                  labels: _buildBaseUnitLabels(theme.textTheme, Size(constraints.maxWidth, constraints.maxHeight)),
                  backgroundColor: backgroundColor,
                  accentColor: accentColor,
                  theta: _getThetaForDuration(widget.duration, widget.baseUnitDenomination),
                  textDirection: Directionality.of(context),
                  textHelper: textHelper,
                ),
              ),
            ));
      }),
    );
  }
}
