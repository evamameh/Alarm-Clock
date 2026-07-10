import 'package:alarmclock/alarm/alarm_app.dart';
import 'package:alarmclock/auth/auth_providers.dart';
import 'package:alarmclock/main.dart';
import 'package:alarmclock/weather/weather_controller.dart';
import 'package:alarmclock/weather/weather_model.dart';
import 'package:alarmclock/weather/weather_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows the login screen when signed out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseInitializationProvider.overrideWith((ref) async {}),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('shows the alarm clock home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherServiceProvider.overrideWithValue(const _FakeWeatherService()),
        ],
        child: const MaterialApp(home: AlarmAppShell()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('RK Rise & Shine'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
  });
}

class _FakeWeatherService extends WeatherService {
  const _FakeWeatherService();

  @override
  Future<WeatherReport> fetchWeather(String query) async {
    return WeatherReport(
      location: const WeatherLocation(
        name: 'Manila',
        country: 'Philippines',
        latitude: 14.6,
        longitude: 120.98,
      ),
      temperature: 30,
      windSpeed: 8,
      weatherCode: 1,
      sunrise: DateTime(2026, 7, 10, 5, 33),
      sunset: DateTime(2026, 7, 10, 18, 29),
      forecast: [
        DailyForecast(
          date: DateTime(2026, 7, 10),
          high: 32,
          low: 26,
          weatherCode: 1,
        ),
      ],
    );
  }
}
