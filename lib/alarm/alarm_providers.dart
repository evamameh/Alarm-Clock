import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../time_formatters.dart';
import 'alarm_controller.dart';
import 'alarm_events.dart';
import 'alarm_model.dart';
import 'alarm_scheduler.dart';

final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) {
  final scheduler = AlarmScheduler();
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final clockProvider = StreamProvider<DateTime>((ref) async* {
  // Emit immediately, then read the device clock again every second. Keeping
  // this separate from the alarm event broadcast prevents the UI from missing
  // the scheduler's first tick and displaying a stale time.
  yield philippineNow();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => philippineNow(),
  );
});

final alarmEventsProvider = StreamProvider<AlarmEvent>((ref) {
  return ref.watch(alarmSchedulerProvider).eventStream;
});

final alarmControllerProvider =
    StateNotifierProvider<AlarmController, AlarmState>((ref) {
      return AlarmController(ref);
    });
