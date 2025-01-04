import 'dart:async';
import 'dart:convert';
import 'package:aahar_app/components/circular_progress.dart';
import 'package:aahar_app/components/auth/sensor_data_screen.dart';
import 'package:aahar_app/components/liquid_progress.dart';
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
      webSocketUrl; // WebSocket server URL (Ensure it's secure, 'wss://')
  late WebSocketChannel _channel;

  StreamSubscription? _streamSubscription; // To manage WebSocket stream

  Map<String, dynamic> _sensorData = {};

  bool _connectionFailed = false; // To track connection failure
  bool _isConnecting = true; // Track connection status
  Timer? _timeoutTimer; // Timer for connection timeout
  bool _isDisposed = false; // To check if the widget is disposed

  double temperature = 0.0;
  double humidity = 0.0;
  double soil_moisture = 0.0;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  /// Safe version of `setState` to prevent calling it when the widget is disposed
  void setStateIfMounted(VoidCallback fn) {
    if (!_isDisposed) {
      setState(fn);
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      // Initialize WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));

      // Start the timeout timer
      _timeoutTimer = Timer(Duration(seconds: 5), () {
        if (_sensorData.isEmpty) {
          setStateIfMounted(() {
            _connectionFailed = true;
            _isConnecting = false;
          });
          _channel.sink.close(status.normalClosure); // Close WebSocket
        }
      });

      // Listen for incoming data
      _streamSubscription = _channel.stream.listen(
        (message) {
          _timeoutTimer?.cancel(); // Cancel the timeout if data is received
          setStateIfMounted(() {
            _sensorData = Map<String, dynamic>.from(jsonDecode(message));
            temperature = (_sensorData['temperature'] is int
                    ? (_sensorData['temperature'] as int).toDouble()
                    : _sensorData['temperature']) ??
                0.0;
            humidity = (_sensorData['humidity'] is int
                    ? (_sensorData['humidity'] as int).toDouble()
                    : _sensorData['humidity']) ??
                0.0;
            soil_moisture = (_sensorData['soil_moisture'] is int
                    ? (_sensorData['soil_moisture'] as int).toDouble()
                    : _sensorData['soil_moisture']) ??
                4095.0;
            print(soil_moisture);
            _isConnecting = false; // Data received, stop loading
          });
        },
        onError: (error) {
          setStateIfMounted(() {
            _connectionFailed = true;
            _isConnecting = false;
          });
        },
        onDone: () {
          if (_sensorData.isEmpty) {
            setStateIfMounted(() {
              _connectionFailed = true;
              _isConnecting = false;
            });
          }
        },
      );
    } catch (e) {
      setStateIfMounted(() {
        _connectionFailed = true;
        _isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark the widget as disposed
    _timeoutTimer?.cancel(); // Cancel the timeout timer
    _streamSubscription?.cancel(); // Cancel the WebSocket stream
    _channel.sink.close(status.normalClosure); // Close WebSocket connection
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
                ? Text(
                    "Connection failed. Please check your network or server.",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    semanticsLabel: "Connection failed message",
                  )
                : _sensorData.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Temp and Humidity",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CircularProgressWidget(
                                  title: "Temperature",
                                  unit: "°C",
                                  foregroundColor: Colors.blue,
                                  progress: temperature,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: CircularProgressWidget(
                                  title: "Humidity",
                                  unit: "%",
                                  foregroundColor: Colors.blue,
                                  progress: humidity,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Soil Health",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          LiquidProgress(
                              label: "Soil Moisture", value: soil_moisture)
                        ],
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
