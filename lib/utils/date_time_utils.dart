import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {

  static Duration parseIso8601Duration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } else {
      return Duration.zero;
    }
  }

  static String durationToIso8601(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return 'PT${hours}H${minutes}M${seconds}S';
  }

  static DateTime convertToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  static String toIso8601StringUTC(DateTime dateTime) {
    final utcDateTime = dateTime.toUtc(); // Convert to UTC
    return DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(utcDateTime);
  }

}