import 'alarm_model.dart';

sealed class AlarmEvent {
  const AlarmEvent();
}

class AlarmTicked extends AlarmEvent {
  const AlarmTicked(this.now);

  final DateTime now;
}

class AlarmTriggered extends AlarmEvent {
  const AlarmTriggered(this.alarm, this.at);

  final AlarmModel alarm;
  final DateTime at;
}
