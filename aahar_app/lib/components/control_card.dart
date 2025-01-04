import 'package:flutter/material.dart';

class ControlCard extends StatefulWidget {
  final String title;
  final bool initialState;
  final ValueChanged<bool> onToggle;
  const ControlCard({
    super.key,
    required this.title,
    this.initialState = false,
    required this.onToggle,
  });

  @override
  State<ControlCard> createState() => _ControlCardState();
}

class _ControlCardState extends State<ControlCard> {
  late bool isControlOn;

  @override
  void initState() {
    super.initState();
    isControlOn = widget.initialState; // Set initial toggle state
  }

  void _toggleControl(bool value) {
    setState(() {
      isControlOn = value;
    });
    widget.onToggle(value); // Notify parent of the change
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              value: isControlOn,
              onChanged: _toggleControl,
              title: Text(
                isControlOn ? 'Control On' : 'Control Off',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
