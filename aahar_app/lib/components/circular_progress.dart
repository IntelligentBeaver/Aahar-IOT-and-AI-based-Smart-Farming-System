import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class CircularProgressWidget extends StatelessWidget {
  // final double temperature; // Current temperature value
  // final double humidity; // Current humidity value
  // final int soilMoistureRaw; // Raw soil moisture value
  // final bool fireSensor; // Fire sensor status (on/off)
  // final bool irrigation; // Irrigation status (on/off)
  final String title;
  final double progress; // Ensure progress is a double type
  final Color foregroundColor;
  final Color backgroundColor;
  final String unit;

  const CircularProgressWidget({
    super.key,
    required this.title,
    required this.progress,
    required this.foregroundColor,
    this.backgroundColor = const Color.fromARGB(255, 238, 231, 231),
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    bool userBackground = false;
    if (backgroundColor == const Color.fromARGB(255, 238, 231, 231)) {
      userBackground = false;
    } else {
      userBackground = true;
    }
    print(progress);
    final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);

    // Update the value notifier whenever progress changes
    _valueNotifier.value = progress;

    return DashedCircularProgressBar(
      width: 375,
      height: 220,
      // width ÷ height
      valueNotifier: _valueNotifier,
      progress: progress,
      startAngle: 225,
      sweepAngle: 270,
      corners: StrokeCap.round,
      foregroundColor: foregroundColor,
      backgroundColor: userBackground
          ? backgroundColor
          : Theme.of(context).colorScheme.onSecondaryContainer,
      foregroundStrokeWidth: 20,
      backgroundStrokeWidth: 20,
      animation: true,
      seekSize: 10,
      seekColor: const Color(0xffeeeeee),
      child: Center(
        child: ValueListenableBuilder(
            valueListenable: _valueNotifier,
            builder: (_, double value, __) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.toStringAsFixed(1)}$unit', // Display value with one decimal point
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 36),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 18),
                    ),
                  ],
                )),
      ),
    );
  }
}
