import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'alarm_events.dart';
import 'alarm_model.dart';
import 'alarm_providers.dart';

class AlarmController extends StateNotifier<AlarmState> {
  AlarmController(this.ref) : super(AlarmState.initial()) {
    _player.setReleaseMode(ReleaseMode.loop);
    ref.read(alarmSchedulerProvider).updateAlarms(state.alarms);
  }

  final Ref ref;
  final AudioPlayer _player = AudioPlayer();

  void setTab(int tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void saveAlarm({
    required TimeOfDay time,
    required Set<int> repeatDays,
    required bool vibrate,
    required int snoozeMinutes,
  }) {
    final alarm = AlarmModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      time: time,
      label: repeatDays.length >= 5 ? 'Work' : 'Personal',
      soundName: 'Pink Sparkle',
      repeatDays: repeatDays,
      vibrate: vibrate,
      snoozeMinutes: snoozeMinutes,
    );

    state = state.copyWith(alarms: [alarm, ...state.alarms], selectedTab: 1);
    ref.read(alarmSchedulerProvider).updateAlarms(state.alarms);
  }

  void toggleAlarm(String alarmId, bool enabled) {
    state = state.copyWith(
      alarms: [
        for (final alarm in state.alarms)
          if (alarm.id == alarmId) alarm.copyWith(enabled: enabled) else alarm,
      ],
    );
    ref.read(alarmSchedulerProvider).updateAlarms(state.alarms);
  }

  Future<void> handleEvent(AlarmEvent event) async {
    switch (event) {
      case AlarmTicked():
        return;
      case AlarmTriggered(:final alarm):
        state = state.copyWith(ringingAlarm: alarm);
        await _playAlarm(alarm);
    }
  }

  Future<void> _playAlarm(AlarmModel alarm) async {
    if (alarm.vibrate) {
      HapticFeedback.heavyImpact();
    }
    await _player.stop();
    await _player.play(AssetSource('alarm1.mp3'));
  }

  Future<void> stopAlarm() async {
    await _player.stop();
    state = state.copyWith(clearRingingAlarm: true);
  }

  Future<void> snooze(AlarmModel alarm) async {
    await _player.stop();
    final nextRing = DateTime.now().add(Duration(minutes: alarm.snoozeMinutes));
    final snoozedAlarm = alarm.copyWith(
      time: TimeOfDay(hour: nextRing.hour, minute: nextRing.minute),
      repeatDays: {},
      enabled: true,
    );
    state = state.copyWith(
      alarms: [
        snoozedAlarm,
        ...state.alarms.where((item) => item.id != alarm.id),
      ],
      clearRingingAlarm: true,
    );
    ref.read(alarmSchedulerProvider).updateAlarms(state.alarms);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
