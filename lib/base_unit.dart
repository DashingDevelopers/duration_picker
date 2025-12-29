/// This enum contains the possible units for the [DurationPicker]
enum BaseUnit {
  millisecond(Duration(milliseconds: 1)),
  second(Duration(seconds: 1)),
  minute(Duration(minutes: 1)),
  hour(Duration(hours: 1));

  final Duration singleUnitDuration;

  const BaseUnit(this.singleUnitDuration);

  // Converts the duration to the chosen secondary unit. For example, for base unit minutes, this gets the number
  // of hours in the duration
  int getDurationInSecondaryUnits(Duration duration) {
    switch (this) {
      case BaseUnit.millisecond:
        return duration.inSeconds;
      case BaseUnit.second:
        return duration.inMinutes;
      case BaseUnit.minute:
        return duration.inHours;
      case BaseUnit.hour:
        return duration.inDays;
    }
  }

  // Converts the duration to the chosen base unit. For example, for base unit minutes, this gets the number of minutes
  // in the duration
  int getDurationInBaseUnits(Duration duration) {
    switch (this) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds;
      case BaseUnit.second:
        return duration.inSeconds;
      case BaseUnit.minute:
        return duration.inMinutes;
      case BaseUnit.hour:
        return duration.inHours;
    }
  }

  // Gets the relation between the base unit and the secondary unit, which is the unit just greater than the base unit.
  // For example if the base unit is second, it will get the number of seconds in a minute
  int getBaseUnitToSecondaryUnitFactor() {
    switch (this) {
      case BaseUnit.millisecond:
        return Duration.millisecondsPerSecond;
      case BaseUnit.second:
        return Duration.secondsPerMinute;
      case BaseUnit.minute:
        return Duration.minutesPerHour;
      case BaseUnit.hour:
        return Duration.hoursPerDay;
    }
  }

  int secondaryUnitHand(Duration duration) {
    return this.getDurationInSecondaryUnits(duration);
  }

  int baseUnitHand(Duration duration) {
    // Result is in [0; num base units in secondary unit - 1], even if overall time is >= 1 secondary unit
    return this.getDurationInBaseUnits(duration) % this.getBaseUnitToSecondaryUnitFactor();
  }
}
