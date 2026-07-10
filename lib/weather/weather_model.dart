import 'package:flutter/foundation.dart';

@immutable
class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.adminArea,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? adminArea;

  String get displayName {
    final area = adminArea == null || adminArea!.isEmpty ? null : adminArea;
    return [name, area, country].whereType<String>().join(', ');
  }
}

@immutable
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.weatherCode,
  });

  final DateTime date;
  final double high;
  final double low;
  final int weatherCode;
}

@immutable
class WeatherReport {
  const WeatherReport({
    required this.location,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.forecast,
  });

  final WeatherLocation location;
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final DateTime sunrise;
  final DateTime sunset;
  final List<DailyForecast> forecast;

  String get condition {
    return switch (weatherCode) {
      0 => 'Clear',
      1 || 2 => 'Partly cloudy',
      3 => 'Cloudy',
      45 || 48 => 'Fog',
      51 || 53 || 55 || 56 || 57 => 'Drizzle',
      61 || 63 || 65 || 66 || 67 => 'Rain',
      71 || 73 || 75 || 77 => 'Snow',
      80 || 81 || 82 => 'Showers',
      95 || 96 || 99 => 'Thunderstorm',
      _ => 'Weather',
    };
  }

  String get icon {
    return switch (weatherCode) {
      0 => 'sunny',
      1 || 2 => 'partly_cloudy_day',
      3 => 'cloud',
      45 || 48 => 'foggy',
      51 || 53 || 55 || 56 || 57 => 'grain',
      61 || 63 || 65 || 66 || 67 => 'rainy',
      71 || 73 || 75 || 77 => 'weather_snowy',
      80 || 81 || 82 => 'water_drop',
      95 || 96 || 99 => 'thunderstorm',
      _ => 'thermostat',
    };
  }
}

@immutable
class WeatherState {
  const WeatherState({
    this.locationQuery = 'Manila',
    this.report,
    this.isLoading = false,
    this.errorMessage,
  });

  final String locationQuery;
  final WeatherReport? report;
  final bool isLoading;
  final String? errorMessage;

  WeatherState copyWith({
    String? locationQuery,
    WeatherReport? report,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WeatherState(
      locationQuery: locationQuery ?? this.locationQuery,
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
