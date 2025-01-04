import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class LiquidProgress extends StatefulWidget {
  final String label;
  final double value;
  const LiquidProgress({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  State<LiquidProgress> createState() => _LiquidProgressState();
}

class _LiquidProgressState extends State<LiquidProgress> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: LiquidLinearProgressIndicator(
            value: 100 - ((widget.value / 4095) * 100),
            valueColor: const AlwaysStoppedAnimation(Colors.green),
            backgroundColor: Colors.grey.shade200,
            borderColor: Colors.green.shade900,
            borderWidth: 2.0,
            borderRadius: 8.0,
            direction: Axis.horizontal,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.value.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
