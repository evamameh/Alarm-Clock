import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'alarm_controller.dart';
import 'alarm_events.dart';
import 'alarm_model.dart';
import 'alarm_scheduler.dart';

final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) {
  final scheduler = AlarmScheduler();
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final clockProvider = StreamProvider<DateTime>((ref) {
  return ref.watch(alarmSchedulerProvider).clockStream;
});

final alarmEventsProvider = StreamProvider<AlarmEvent>((ref) {
  return ref.watch(alarmSchedulerProvider).eventStream;
});

final alarmControllerProvider =
    StateNotifierProvider<AlarmController, AlarmState>((ref) {
      return AlarmController(ref);
    });
