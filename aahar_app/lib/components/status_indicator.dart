import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String title; // Title for the attribute
  final bool isActive; // On/Off status
  final Color activeColor; // Color when active
  final Color inactiveColor; // Color when inactive

  const StatusIndicator({
    super.key,
    required this.title,
    required this.isActive,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
