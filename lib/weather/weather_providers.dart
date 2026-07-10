import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'weather_controller.dart';
import 'weather_model.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return const WeatherService();
});

final weatherControllerProvider =
    StateNotifierProvider<WeatherController, WeatherState>((ref) {
      return WeatherController(ref.watch(weatherServiceProvider));
    });
