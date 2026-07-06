import 'dart:async';

import 'alarm_events.dart';
import 'alarm_model.dart';

class AlarmScheduler {
  AlarmScheduler() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    _onTick();
  }

  final _clockController = StreamController<DateTime>.broadcast();
  final _eventController = StreamController<AlarmEvent>.broadcast();
  final Set<String> _triggeredMinuteKeys = {};
  Timer? _timer;
  List<AlarmModel> _alarms = const [];

  Stream<DateTime> get clockStream => _clockController.stream;
  Stream<AlarmEvent> get eventStream => _eventController.stream;

  void updateAlarms(List<AlarmModel> alarms) {
    _alarms = alarms;
  }

  void _onTick() {
    final now = DateTime.now();
    _clockController.add(now);
    _eventController.add(AlarmTicked(now));

    for (final alarm in _alarms) {
      final key =
          '${alarm.id}-${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';
      if (alarm.shouldRingAt(now) && !_triggeredMinuteKeys.contains(key)) {
        _triggeredMinuteKeys.add(key);
        _eventController.add(AlarmTriggered(alarm, now));
      }
    }

    if (now.second == 5) {
      _triggeredMinuteKeys.removeWhere(
        (key) => !key.endsWith('-${now.hour}-${now.minute}'),
      );
    }
  }

  void dispose() {
    _timer?.cancel();
    _clockController.close();
    _eventController.close();
  }
}
