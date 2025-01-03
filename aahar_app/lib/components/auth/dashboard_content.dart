import 'dart:async';
import 'dart:convert';
import 'package:aahar_app/components/auth/circular_progress.dart';
import 'package:aahar_app/components/auth/sensor_data_screen.dart';
import 'package:aahar_app/components/secrets.dart';
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
  final String _webSocketUrl =
      'ws://192.168.80.187:3000/'; // Secure WebSocket URL
  late WebSocketChannel _channel;
  Map<String, dynamic> _sensorData = {};
  bool _connectionFailed = false;
  bool _isConnecting = true; // Track connection status
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      // Initialize WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));

      // Start the timeout timer
      _timeoutTimer = Timer(Duration(milliseconds: 100), () {
        if (_sensorData.isEmpty) {
          setState(() {
            _connectionFailed = true;
            _isConnecting = false;
          });
          _channel.sink.close(status.normalClosure);
        }
      });

      // Listen for incoming data
      _channel.stream.listen(
        (message) {
          _timeoutTimer?.cancel();
          setState(() {
            _sensorData = Map<String, dynamic>.from(jsonDecode(message));
            _isConnecting = false; // Data received, stop loading
          });
        },
        onError: (error) {
          setState(() {
            _connectionFailed = true;
            _isConnecting = false;
          });
        },
        onDone: () {
          if (_sensorData.isEmpty) {
            setState(() {
              _connectionFailed = true;
              _isConnecting = false;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _connectionFailed = true;
        _isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _channel.sink.close(status.normalClosure);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isConnecting
            ? Center(
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 6,
                  semanticsLabel: "Connecting to the server...",
                ),
              )
            : _connectionFailed
                ? Center(
                    child: Text(
                      "Connection failed. Please try again.",
                      style: TextStyle(color: Colors.red, fontSize: 18),
                      semanticsLabel: "Connection failed message",
                    ),
                  )
                : _sensorData.isNotEmpty
                    ? CircularProgressWidget(
                        temperature: _sensorData['Temperature'] ?? 0.0,
                        humidity: _sensorData['Humidity'] ?? 0.0,
                        soilMoistureRaw: _sensorData['Soil Moisture'] ?? 4095,
                        fireSensor: _sensorData['Fire Sensor'] == 1,
                        irrigation: _sensorData['Irrigation'] == 1,
                      )
                    : Center(
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 6,
                          semanticsLabel: "Loading sensor data...",
                        ),
                      ),
      ),
    );
  }
}
