import 'package:aahar_app/components/auth/led_service.dart';
import 'package:aahar_app/components/auth/pump_service.dart';
import 'package:aahar_app/components/secrets.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Control extends StatefulWidget {
  const Control({super.key});
  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  late List<Map<String, dynamic>> controls;
  late List<Function> functionsname; // Store functions
  late TextEditingController durationController;
  bool isCountingDown = false; // Whether countdown has started
  int countdownValue = 0; // Remaining seconds for countdown
  Timer? countdownTimer;
  bool isLoading = false; // Show loading indicator during backend request

  @override
  void initState() {
    super.initState();
    controls = [
      {"name": "LED", "state": false},
      {"name": "Pump", "state": false},
    ];

    functionsname = [
      toggleLED,
      togglePump,
    ];

    durationController = TextEditingController();
  }

  // Toggle LED
  void toggleLED() async {
    setState(() {
      controls[0]['state'] = !(controls[0]['state'] as bool);
    });

    if (controls[0]['state'] == true) {
      final ledService = LEDService();
      // Send LED state to the backend and wait for the response
      final ledResponse = await ledService.sendToBackend(controls);

      if (ledResponse.containsKey('success') &&
          ledResponse['success'] == true) {
        print('LED state updated successfully: ${ledResponse['success']}');
      }
    } else {
      final ledService = LEDService();
      // Send LED state to the backend and wait for the response
      final ledResponse = await ledService.sendToBackend(controls);
      if (ledResponse.containsKey('success') &&
          ledResponse['success'] == false) {
        final ledService = LEDService();
        // Send LED state to the backend and wait for the response
        final ledResponse = await ledService.sendToBackend(controls);
      }
    }
  }

  // Toggle Pump and show the input dialog
  void togglePump() {
    setState(() {
      controls[1]['state'] = !(controls[1]['state'] as bool);
    });

    if (controls[1]['state'] == true) {
      // Show dialog to get the duration when the pump is turned on
      _showDurationDialog();
    } else {
      // Stop the countdown if the pump is turned off
      if (countdownTimer != null) {
        countdownTimer?.cancel();
      }
      setState(() {
        isCountingDown = false;
        countdownValue = 0;
      });

      // Inform backend that the pump is turned off
      final pumpService = PumpService();
      final response = pumpService.sendPumpStateToBackend(controls[1]['state']);
    }
  }

  // Show dialog to ask the user for duration
  void _showDurationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter duration for the pump (seconds)'),
          content: TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Duration in seconds",
              focusedBorder: Theme.of(context)
                  .inputDecorationTheme
                  .focusedBorder
                  ?.copyWith(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final duration = int.tryParse(durationController.text);
                if (duration != null && duration > 0) {
                  setState(() {
                    isLoading = true; // Show loading indicator
                  });

                  // Send the duration to the backend and receive response
                  final pumpService = PumpService();
                  final response = await pumpService.sendDurationToBackend(
                      duration, controls);

                  if (response.containsKey("message") &&
                      response["message"].isNotEmpty) {
                    // This checks if the response contains the "message" key and it's not empty
                    setState(() {
                      countdownValue = duration;
                      isCountingDown = true;
                      isLoading = false; // Hide loading indicator
                    });
                    // After the backend acknowledges, start the countdown
                    _startCountdown();
                  } else {
                    setState(() {
                      isLoading = false; // Hide loading indicator
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error from backend')));
                  }
                  Navigator.of(context).pop(); // Close the dialog
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

  // Start the countdown for the pump
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
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 400, // Set a fixed height for better scrolling
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controls.length, // Total number of items
            itemBuilder: (context, index) {
              final control = controls[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        control['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: isLoading && index == 1
                          ? CircularProgressIndicator() // Show loading indicator when the pump is on
                          : Switch(
                              value: control['state'],
                              onChanged: (value) {
                                functionsname[index]();
                              },
                            ),
                    ),
                    if (isCountingDown && index == 1)
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
            },
          ),
        ),
      ),
    );
  }
}
