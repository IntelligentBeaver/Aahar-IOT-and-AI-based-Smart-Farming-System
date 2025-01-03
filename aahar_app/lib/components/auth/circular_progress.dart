import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';

class CircularProgress extends StatelessWidget {
  final String title;
  final double progress; // Ensure progress is a double type
  final Color foregroundColor;
  final Color backgroundColor;
  final String unit;
  CircularProgress({
    super.key,
    required this.title,
    required this.foregroundColor,
    this.backgroundColor = const Color.fromARGB(255, 238, 231, 231),
    required this.unit,
    required this.progress,
  });

  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
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
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
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
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 36),
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
