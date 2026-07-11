import 'package:alarmclock/alarm/alarm_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlarmModel.shouldRingAt', () {
    test('rings during the selected minute even after second zero', () {
      const alarm = AlarmModel(
        id: 'alarm',
        time: TimeOfDay(hour: 7, minute: 30),
        label: 'Test',
        soundName: 'Pink Sparkle',
        repeatDays: {6},
      );

      expect(alarm.shouldRingAt(DateTime(2026, 7, 11, 7, 30, 42)), isTrue);
    });

    test('does not ring on a day that is not selected', () {
      const alarm = AlarmModel(
        id: 'alarm',
        time: TimeOfDay(hour: 7, minute: 30),
        label: 'Test',
        soundName: 'Pink Sparkle',
        repeatDays: {1, 2, 3, 4, 5},
      );

      expect(alarm.shouldRingAt(DateTime(2026, 7, 11, 7, 30)), isFalse);
    });
  });
}
