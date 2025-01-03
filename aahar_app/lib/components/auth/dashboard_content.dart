import 'dart:async';
import 'dart:convert';
import 'package:aahar_app/components/auth/circular_progress.dart';
import 'package:aahar_app/components/auth/sensor_data_screen.dart';
import 'package:aahar_app/providers/control_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final String _webSocketUrl = 'ws://172.16.1.48:3000'; // WebSocket server URL
  late WebSocketChannel _channel;
  Map<String, dynamic> _sensorData = {};
  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));

    // Listen for incoming data
    _channel.stream.listen((message) {
      setState(() {
        _sensorData = Map<String, dynamic>.from(jsonDecode(message));
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure); // Close connection
    super.dispose();
  }

  Widget build(BuildContext context) {
    Provider.of<ControlProvider>(context);
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sensorData.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _sensorData.entries.map((entry) {
                  return Text("${entry.key}: ${entry.value}");
                }).toList(),
              )
            : Center(
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 6,
                ),
              ),
      ),
    );
  }
}
