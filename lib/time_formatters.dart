import 'package:flutter/material.dart';

String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatClock(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  return '${twoDigits(hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
}

String periodFor(DateTime time) {
  return time.hour >= 12 ? 'PM' : 'AM';
}

String periodForTimeOfDay(TimeOfDay time) {
  return time.period == DayPeriod.pm ? 'PM' : 'AM';
}

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  return '${twoDigits(hour)}:${twoDigits(time.minute)}';
}

String formatDate(DateTime time) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[time.weekday - 1]}, ${months[time.month - 1]} ${time.day}'
      .toUpperCase();
}
