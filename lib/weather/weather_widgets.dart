import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../theme.dart';
import '../time_formatters.dart';
import 'weather_model.dart';
import 'weather_providers.dart';

const _weatherPlaces = <String>[
  'Manila',
  'Quezon City',
  'Makati',
  'Pasig',
  'Taguig',
  'Baguio',
  'Batangas City',
  'Legazpi',
  'Cebu City',
  'Iloilo City',
  'Bacolod',
  'Tacloban',
  'Cagayan de Oro',
  'Davao City',
  'General Santos',
  'Zamboanga City',
];

class WeatherPanel extends ConsumerWidget {
  const WeatherPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherControllerProvider);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: softWeatherPanel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: AppColors.rose),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Weather',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Refresh weather',
                color: AppColors.roseDark,
                onPressed: weather.isLoading
                    ? null
                    : () => ref
                          .read(weatherControllerProvider.notifier)
                          .loadWeather(weather.locationQuery),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _weatherPlaces.contains(weather.locationQuery)
                ? weather.locationQuery
                : _weatherPlaces.first,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Weather location',
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: [
              for (final place in _weatherPlaces)
                DropdownMenuItem(value: place, child: Text(place)),
            ],
            onChanged: weather.isLoading
                ? null
                : (place) {
                    if (place != null) {
                      ref
                          .read(weatherControllerProvider.notifier)
                          .loadWeather(place);
                    }
                  },
          ),
          const SizedBox(height: 18),
          if (weather.isLoading && weather.report == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: CircularProgressIndicator(color: AppColors.rose),
              ),
            )
          else if (weather.errorMessage != null && weather.report == null)
            _WeatherError(message: weather.errorMessage!)
          else if (weather.report != null)
            _WeatherReportView(report: weather.report!),
          if (weather.errorMessage != null && weather.report != null) ...[
            const SizedBox(height: 14),
            _WeatherError(message: weather.errorMessage!),
          ],
        ],
      ),
    );
  }
}

class _WeatherReportView extends StatelessWidget {
  const _WeatherReportView({required this.report});

  final WeatherReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_weatherIcon(report.icon), color: AppColors.rose, size: 54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.location.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.roseDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    report.condition,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${report.temperature.round()} deg C',
              style: const TextStyle(
                color: AppColors.rose,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _WeatherFact(
                icon: Icons.air,
                label: 'Wind',
                value: '${report.windSpeed.round()} km/h',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherFact(
                icon: Icons.wb_twilight,
                label: 'Sunrise',
                value: _formatShortTime(report.sunrise),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherFact(
                icon: Icons.nights_stay_outlined,
                label: 'Sunset',
                value: _formatShortTime(report.sunset),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (final day in report.forecast)
              Expanded(child: _ForecastDay(day: day)),
          ],
        ),
      ],
    );
  }
}

class _WeatherFact extends StatelessWidget {
  const _WeatherFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.rose, size: 21),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.roseDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastDay extends StatelessWidget {
  const _ForecastDay({required this.day});

  final DailyForecast day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.blush.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              _dayLabel(day.date),
              style: const TextStyle(
                color: AppColors.roseDark,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Icon(_weatherIconForCode(day.weatherCode), color: AppColors.rose),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${day.high.round()} / ${day.low.round()} deg',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherError extends StatelessWidget {
  const _WeatherError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blush.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.roseDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

BoxDecoration softWeatherPanel() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: AppColors.rose.withValues(alpha: 0.08),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

IconData _weatherIcon(String icon) {
  return switch (icon) {
    'sunny' => Icons.wb_sunny_outlined,
    'partly_cloudy_day' => Icons.wb_cloudy_outlined,
    'cloud' => Icons.cloud_outlined,
    'foggy' => Icons.foggy,
    'grain' => Icons.grain,
    'rainy' => Icons.water_drop_outlined,
    'weather_snowy' => Icons.ac_unit,
    'water_drop' => Icons.umbrella_outlined,
    'thunderstorm' => Icons.thunderstorm_outlined,
    _ => Icons.thermostat,
  };
}

IconData _weatherIconForCode(int code) {
  final report = WeatherReport(
    location: const WeatherLocation(
      name: '',
      country: '',
      latitude: 0,
      longitude: 0,
    ),
    temperature: 0,
    windSpeed: 0,
    weatherCode: code,
    sunrise: DateTime(2026),
    sunset: DateTime(2026),
    forecast: const [],
  );
  return _weatherIcon(report.icon);
}

String _formatShortTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '${twoDigits(hour)}:${twoDigits(value.minute)} ${periodFor(value)}';
}

String _dayLabel(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}
