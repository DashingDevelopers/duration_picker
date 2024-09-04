import 'dart:math' as math;

const Duration kDialAnimateDuration = Duration(milliseconds: 200);

const double kDurationPickerWidthPortrait = 328.0;
const double kDurationPickerWidthLandscape = 512.0;

const double kDurationPickerHeightPortrait = 410.0;
//PR  the height for landscape seemed too small, especially now the rendered size is smaller
const double kDurationPickerHeightLandscape = 380.0;

const double kTwoPi = 2 * math.pi; // 360 degrees in radians
const double kPiByTwo = math.pi / 2; // 90 degrees in radians

const double kCircleTop = kPiByTwo;





/// The [DurationPicker] widget.
