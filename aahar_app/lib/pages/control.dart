// control.dart
import 'package:flutter/material.dart';
import 'package:aahar_app/components/auth/led_service.dart';
import 'package:aahar_app/components/auth/pump_service.dart';
import 'dart:async';

class Control extends StatefulWidget {
  const Control({super.key});

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  late List<Map<String, dynamic>> controls;
  late List<Function> functionsname;
  late TextEditingController durationController;
  bool isCountingDown = false;
  int countdownValue = 0;
  Timer? countdownTimer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controls = [
      {"name": "LED", "state": false},
      {"name": "Pump", "state": false},
    ];
    functionsname = [toggleLED, togglePump];
    durationController = TextEditingController();
  }

  void toggleLED() async {
    setState(() {
      controls[0]['state'] = !(controls[0]['state'] as bool);
    });

    final ledService = LEDService();
    final response = await ledService.sendToBackend(controls);
    if (response.containsKey('error')) {
      // Handle error response
      print(response['error']);
    }
  }

  void togglePump() {
    setState(() {
      controls[1]['state'] = !(controls[1]['state'] as bool);
    });

    if (controls[1]['state'] == true) {
      _showDurationDialog();
    } else {
      if (countdownTimer != null) {
        countdownTimer?.cancel();
      }
      setState(() {
        isCountingDown = false;
        countdownValue = 0;
      });
    }
  }

  void _showDurationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter duration for the pump (seconds)'),
          content: TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Duration in seconds"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final duration = int.tryParse(durationController.text);
                if (duration != null && duration > 0) {
                  setState(() {
                    isLoading = true;
                  });

                  final pumpService = PumpService();
                  final response = await pumpService.sendDurationToBackend(
                      duration, controls);

                  if (response.containsKey("message") &&
                      response["message"].isNotEmpty) {
                    setState(() {
                      countdownValue = duration;
                      isCountingDown = true;
                      isLoading = false;
                    });
                    _startCountdown();
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error from backend')));
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid number')));
                }
              },
              child: Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdownValue > 0) {
          countdownValue--;
        } else {
          countdownTimer?.cancel();
          setState(() {
            isCountingDown = false;
            controls[1]['state'] = !(controls[1]['state'] as bool);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: controls.length,
            itemBuilder: (context, index) {
              final control = controls[index];
              return ControlTile(
                control: control,
                onSwitchChanged: functionsname[index],
                isLoading: isLoading && index == 1,
                countdownValue: countdownValue,
                isCountingDown: isCountingDown,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ControlTile extends StatelessWidget {
  final Map<String, dynamic> control;
  final Function onSwitchChanged;
  final bool isLoading;
  final int countdownValue;
  final bool isCountingDown;

  const ControlTile({
    required this.control,
    required this.onSwitchChanged,
    required this.isLoading,
    required this.countdownValue,
    required this.isCountingDown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              control['name'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            trailing: isLoading
                ? CircularProgressIndicator()
                : Switch(
                    value: control['state'],
                    onChanged: (value) {
                      onSwitchChanged();
                    },
                  ),
          ),
          if (isCountingDown && control['name'] == 'Pump')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Countdown: $countdownValue seconds',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}
