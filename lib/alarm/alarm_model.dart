import 'package:flutter/material.dart';

@immutable
class AlarmModel {
  const AlarmModel({
    required this.id,
    required this.time,
    required this.label,
    required this.soundName,
    required this.repeatDays,
    this.enabled = true,
    this.vibrate = true,
    this.snoozeMinutes = 5,
  });

  final String id;
  final TimeOfDay time;
  final String label;
  final String soundName;
  final Set<int> repeatDays;
  final bool enabled;
  final bool vibrate;
  final int snoozeMinutes;

  AlarmModel copyWith({
    TimeOfDay? time,
    String? label,
    String? soundName,
    Set<int>? repeatDays,
    bool? enabled,
    bool? vibrate,
    int? snoozeMinutes,
  }) {
    return AlarmModel(
      id: id,
      time: time ?? this.time,
      label: label ?? this.label,
      soundName: soundName ?? this.soundName,
      repeatDays: repeatDays ?? this.repeatDays,
      enabled: enabled ?? this.enabled,
      vibrate: vibrate ?? this.vibrate,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  bool shouldRingAt(DateTime now) {
    if (!enabled) return false;
    if (repeatDays.isNotEmpty && !repeatDays.contains(now.weekday)) {
      return false;
    }
    return now.hour == time.hour &&
        now.minute == time.minute &&
        now.second == 0;
  }
}

@immutable
class AlarmState {
  const AlarmState({
    required this.alarms,
    this.ringingAlarm,
    this.selectedTab = 0,
  });

  factory AlarmState.initial() {
    return const AlarmState(alarms: []);
  }

  final List<AlarmModel> alarms;
  final AlarmModel? ringingAlarm;
  final int selectedTab;

  AlarmState copyWith({
    List<AlarmModel>? alarms,
    AlarmModel? ringingAlarm,
    bool clearRingingAlarm = false,
    int? selectedTab,
  }) {
    return AlarmState(
      alarms: alarms ?? this.alarms,
      ringingAlarm: clearRingingAlarm
          ? null
          : ringingAlarm ?? this.ringingAlarm,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
