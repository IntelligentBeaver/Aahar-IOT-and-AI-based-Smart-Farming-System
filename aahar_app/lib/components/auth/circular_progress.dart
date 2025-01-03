import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class CircularProgressWidget extends StatelessWidget {
  final double temperature; // Current temperature value
  final double humidity; // Current humidity value
  final double soilMoistureRaw; // Raw soil moisture value
  final bool fireSensor; // Fire sensor status (on/off)
  final bool irrigation; // Irrigation status (on/off)

  const CircularProgressWidget({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.soilMoistureRaw,
    required this.fireSensor,
    required this.irrigation,
  });

  @override
  Widget build(BuildContext context) {
    // Convert raw soil moisture to percentage (assuming 4095 is 100%)
    final soilMoisturePercentage = ((4095 - soilMoistureRaw) / 4095) * 100;

    return Column(
      children: [
        // Temperature Circular Progress
        _buildCircularProgressBar(
          context,
          label: "Temperature",
          value: temperature,
          maxValue: 50, // Assuming 50°C as the maximum temperature
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.orange],
          ),
        ),
        const SizedBox(height: 20),

        // Humidity Circular Progress
        _buildCircularProgressBar(
          context,
          label: "Humidity",
          value: humidity,
          maxValue: 100, // Humidity is in percentage
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        const SizedBox(height: 20),

        // Soil Moisture Liquid Progress Indicator
        _buildLiquidProgressIndicator(
          context,
          label: "Soil Moisture",
          value: soilMoisturePercentage,
        ),
        const SizedBox(height: 20),

        // Fire Sensor and Irrigation Status
        _buildStatusRow(
          context,
          status1: fireSensor,
          label1: "Fire Sensor",
          status2: irrigation,
          label2: "Irrigation",
        ),
      ],
    );
  }

  Widget _buildCircularProgressBar(BuildContext context,
      {required String label,
      required double value,
      required double maxValue,
      required Gradient gradient}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DashedCircularProgressBar.aspectRatio(
          aspectRatio: 1,
          backgroundColor: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${value.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidProgressIndicator(
    BuildContext context, {
    required String label,
    required double value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: LiquidCircularProgressIndicator(
            value: value / 100,
            valueColor: const AlwaysStoppedAnimation(Colors.green),
            backgroundColor: Colors.grey.shade200,
            borderColor: Colors.green.shade900,
            borderWidth: 2.0,
            direction: Axis.vertical,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${value.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context,
      {required bool status1,
      required String label1,
      required bool status2,
      required String label2}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusIndicator(label1, status1),
        _buildStatusIndicator(label2, status2),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, bool status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          status ? Icons.check_circle : Icons.cancel,
          color: status ? Colors.green : Colors.red,
          size: 36,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
