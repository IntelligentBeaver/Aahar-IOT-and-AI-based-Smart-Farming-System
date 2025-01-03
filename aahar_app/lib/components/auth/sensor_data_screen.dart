import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class SensorDataScreen extends StatefulWidget {
  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Real-time Sensor Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sensorData.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _sensorData.entries.map((entry) {
                  return Text("${entry.key}: ${entry.value}");
                }).toList(),
              )
            : Center(
                child: Text("Waiting for data..."),
              ),
      ),
    );
  }
}
