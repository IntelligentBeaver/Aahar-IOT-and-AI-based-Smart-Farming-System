import 'package:flutter/material.dart';

class DailyForecast extends StatelessWidget {
  final String day;
  final String temperature;
  final String weatherCondition;

  const DailyForecast({
    super.key,
    required this.day,
    required this.temperature,
    required this.weatherCondition,
  });

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case "Clear":
        return Icons.wb_sunny;
      case "Clouds":
        return Icons.cloud;
      case "Rain":
        return Icons.umbrella;
      case "Snow":
        return Icons.ac_unit;
      case "Thunderstorm":
        return Icons.flash_on;
      default:
        return Icons.help_outline; // Default for unknown conditions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              day,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(
                  _getWeatherIcon(weatherCondition),
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  temperature,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
