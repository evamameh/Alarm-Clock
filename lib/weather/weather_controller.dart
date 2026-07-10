import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import 'weather_model.dart';

class WeatherController extends StateNotifier<WeatherState> {
  WeatherController(this._service) : super(const WeatherState()) {
    loadWeather(state.locationQuery);
  }

  final WeatherService _service;

  Future<void> loadWeather(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      locationQuery: trimmed,
      isLoading: true,
      clearError: true,
    );

    try {
      final report = await _service.fetchWeather(trimmed);
      state = state.copyWith(report: report, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyWeatherError(error),
      );
    }
  }
}

class WeatherService {
  const WeatherService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<WeatherReport> fetchWeather(String query) async {
    final client = _client ?? http.Client();
    try {
      final location = await _searchLocation(client, query);
      final weather = await _fetchForecast(client, location);
      return weather;
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<WeatherLocation> _searchLocation(
    http.Client client,
    String query,
  ) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '1',
      'language': 'en',
      'format': 'json',
    });
    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw const WeatherException('Location search failed.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw WeatherException('No weather location found for "$query".');
    }

    final first = results.first as Map<String, dynamic>;
    return WeatherLocation(
      name: first['name'] as String? ?? query,
      country: first['country'] as String? ?? '',
      adminArea: first['admin1'] as String?,
      latitude: (first['latitude'] as num).toDouble(),
      longitude: (first['longitude'] as num).toDouble(),
    );
  }

  Future<WeatherReport> _fetchForecast(
    http.Client client,
    WeatherLocation location,
  ) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '3',
    });
    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw const WeatherException('Weather forecast failed.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>;
    final daily = body['daily'] as Map<String, dynamic>;
    final dates = daily['time'] as List<dynamic>;
    final highs = daily['temperature_2m_max'] as List<dynamic>;
    final lows = daily['temperature_2m_min'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final sunrises = daily['sunrise'] as List<dynamic>;
    final sunsets = daily['sunset'] as List<dynamic>;

    return WeatherReport(
      location: location,
      temperature: (current['temperature_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      sunrise: DateTime.parse(sunrises.first as String),
      sunset: DateTime.parse(sunsets.first as String),
      forecast: [
        for (var i = 0; i < dates.length; i++)
          DailyForecast(
            date: DateTime.parse(dates[i] as String),
            high: (highs[i] as num).toDouble(),
            low: (lows[i] as num).toDouble(),
            weatherCode: (codes[i] as num).toInt(),
          ),
      ],
    );
  }
}

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;
}

String _friendlyWeatherError(Object error) {
  if (error is WeatherException) return error.message;
  return 'Unable to load weather. Check your internet connection.';
}
