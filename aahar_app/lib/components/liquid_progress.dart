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
    double soilValue = 100 - ((widget.value / 4095) * 100);
    // Round the value to 1 decimal place before using it
    soilValue = double.parse(soilValue.toStringAsFixed(1));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          width: double.infinity,
          child: LiquidLinearProgressIndicator(
            value: 1 - (widget.value / 4095),
            valueColor: const AlwaysStoppedAnimation(Colors.green),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            borderColor: Theme.of(context).colorScheme.onSecondaryContainer,
            borderWidth: 0,
            borderRadius: 12.0,
            direction: Axis.horizontal,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$soilValue%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
