import 'dart:math' as math;

import 'package:duration_picker/base_unit.dart';
import 'package:duration_picker/constants.dart';
import 'package:duration_picker/dial/text.dart';
import 'package:duration_picker/localization/localization.dart';
import 'package:flutter/material.dart';

/// Use [DialPainter] to style the durationPicker to your style.
class DialPainter extends CustomPainter {
  final TextHelper textHelper;

  const DialPainter({
    required this.context,
    required this.labels,
    required this.backgroundColor,
    required this.accentColor,
    required this.theta, //Measured angle in radians
    required this.textDirection,
    // required this.selectedValue,
    required this.baseUnitMultiplier,
    required this.baseUnitHand,
    required this.baseUnit,
    required TextHelper this.textHelper,
  });

  final List<TextPainter> labels;
  final Color? backgroundColor;
  final Color accentColor;
  final double theta;
  final TextDirection textDirection;
  // final int? selectedValue;
  final BuildContext context;

  final int baseUnitMultiplier;
  final int baseUnitHand;
  final BaseUnit baseUnit;

  @override
  void paint(Canvas canvas, Size size) {
    const epsilon = .001;
    const sweep = kTwoPi - epsilon;
    const startAngle = -math.pi / 2.0;
    final durationBaseSize = 20;


    //PR reduce radius to enclose the handle shape
    final radius = (size.shortestSide / 2.0) - 20;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final centerPoint = center;

    final pctTheta = (0.25 - (theta % kTwoPi) / kTwoPi) % 1.0;

    // Draw the background outer ring
    canvas.drawCircle(centerPoint, radius, Paint()..color = backgroundColor!);

    // Draw a translucent circle for every secondary unit
    for (var i = 0; i < baseUnitMultiplier; i = i + 1) {
      canvas.drawCircle(
        centerPoint,
        radius,
        Paint()..color = accentColor.withOpacity((i == 0) ? 0.3 : 0.1),
      );
    }

    // Draw the inner background circle
    canvas.drawCircle(
      centerPoint,
      radius * 0.88,
      Paint()..color = Theme.of(context).canvasColor,
    );

    // Get the offset point for an angle value of theta, and a distance of _radius
    Offset getOffsetForTheta(double theta, double radius) {
      return center + Offset(radius * math.cos(theta), -radius * math.sin(theta));
    }

    // Draw the handle that is used to drag and to indicate the position around the circle
    final handlePaint = Paint()..color = accentColor;
    //PR center the handle against new outer ring size
    final handlePoint = getOffsetForTheta(theta, radius - 5.0*MediaQuery.of(context).textScaleFactor);
    canvas.drawCircle(handlePoint, 13.0*MediaQuery.of(context).textScaleFactor, handlePaint);

    final textDurationValuePainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: textHelper.durationString,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            //PR shrink font as circle is now smaller
            .copyWith(fontSize:  durationBaseSize * MediaQuery.of(context).textScaleFactor),
      ),
      textDirection: textDirection, //TextDirection.ltr,
    )..layout();
    final middleForValueText = Offset(
      centerPoint.dx - (textDurationValuePainter.width / 2),
      centerPoint.dy - textDurationValuePainter.height / 2,
    );
    textDurationValuePainter.paint(canvas, middleForValueText);

    // final textMinPainter = TextPainter(
    //   textAlign: TextAlign.center,
    //   text: TextSpan(
    //     text: getBaseUnitString(), //th: ${theta}',
    //     //PR shrink font as its resized elsewhere
    //     style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: size.shortestSide * 0.06),
    //   ),
    //   textDirection: TextDirection.ltr,
    // )..layout();
    // textMinPainter.paint(
    //   canvas,
    //   Offset(
    //     centerPoint.dx - (textMinPainter.width / 2),
    //     centerPoint.dy +
    //         (textDurationValuePainter.height / 2) -
    //         textMinPainter.height / 2,
    //   ),
    // );

    // Draw an arc around the circle for the amount of the circle that has elapsed.
    final elapsedPainter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withOpacity(0.3)
      ..isAntiAlias = true
      ..strokeWidth = radius * 0.12;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: radius - radius * 0.12 / 2,
      ),
      startAngle,
      sweep * pctTheta,
      false,
      elapsedPainter,
    );

    // Paint the labels (the minute strings)
    void paintLabels(List<TextPainter> labels) {
      final labelThetaIncrement = -kTwoPi / labels.length;
      var labelTheta = kPiByTwo;

      for (final label in labels) {
        var widthDif = -label.width / 2.0;
        var heightDif = -label.height / 2.0;

        final labelOffset = Offset(widthDif, heightDif);

        label.paint(
          canvas,
          getOffsetForTheta(labelTheta, radius * .7) + labelOffset,
        );

        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(labels);
  }

  @override
  bool shouldRepaint(DialPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.theta != theta;
  }
}

/// The [DurationPicker] widget.
