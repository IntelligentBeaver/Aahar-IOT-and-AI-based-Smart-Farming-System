import 'package:flutter/material.dart';

class HourlyForecast extends StatelessWidget {
  final String time;
  final String temperature;
  final String weatherCondition; // Added weatherCondition as a parameter

  const HourlyForecast({
    super.key,
    required this.time,
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
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.fade,
            ),
            const SizedBox(height: 8),
            Icon(
              _getWeatherIcon(weatherCondition), // Dynamically get icon
              size: 42,
            ),
            const SizedBox(height: 8),
            Text(temperature),
          ],
        ),
      ),
    );
  }
}
