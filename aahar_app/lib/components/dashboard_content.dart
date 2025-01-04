import 'dart:async';
import 'dart:convert';
import 'package:aahar_app/components/circular_progress.dart';
import 'package:aahar_app/components/liquid_progress.dart';
import 'package:aahar_app/components/secrets.dart';
import 'package:aahar_app/components/status_indicator.dart';
import 'package:flutter/material.dart';
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
  StreamSubscription? _streamSubscription;
  Map<String, dynamic> _sensorData = {};
  bool _connectionFailed = false;
  Timer? _timeoutTimer;
  bool _isDisposed = false;
  bool _isLoading = false;
  String? _errorMessage; // Store error message

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
      setStateIfMounted(() {
        _isLoading = true;
        _errorMessage = null; // Clear previous errors
      });

      // Initialize WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));

      // Start the timeout timer
      _timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (_sensorData.isEmpty) {
          setStateIfMounted(() {
            _connectionFailed = true;
            _isLoading = false;
          });
          _channel.sink.close(status.normalClosure);
        }
      });

      // Listen for incoming data
      _streamSubscription = _channel.stream.listen(
        (message) {
          _timeoutTimer?.cancel();
          setStateIfMounted(() {
            _sensorData = Map<String, dynamic>.from(jsonDecode(message));
            print(_sensorData);
            temperature = (_sensorData['temperature']?.toDouble() ?? 0.0);
            humidity = (_sensorData['humidity']?.toDouble() ?? 0.0);
            soil_moisture =
                (_sensorData['soil_moisture']?.toDouble() ?? 4095.0);
            _isLoading = false;
          });
        },
        onError: (error) {
          setStateIfMounted(() {
            _connectionFailed = true;
            _isLoading = false;
            _errorMessage = error.toString(); // Capture error message
          });
        },
        onDone: () {
          if (_sensorData.isEmpty) {
            setStateIfMounted(() {
              _connectionFailed = true;
              _isLoading = false;
              _errorMessage = "Connection closed by server.";
            });
          }
        },
      );
    } catch (e) {
      setStateIfMounted(() {
        _connectionFailed = true;
        _isLoading = false;
        _errorMessage = e.toString(); // Capture error message
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timeoutTimer?.cancel();
    _streamSubscription?.cancel();
    _channel.sink.close(status.normalClosure);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 6,
                  semanticsLabel: "Connecting to the server...",
                ),
              )
            : _connectionFailed
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _connectWebSocket,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : _sensorData.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
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
                                  foregroundColor: Colors.red,
                                  progress: temperature,
                                ),
                              ),
                              const SizedBox(width: 20),
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
                          const SizedBox(height: 20),
                          const Text(
                            "Soil Health",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          LiquidProgress(
                            label: "Soil Moisture",
                            value: soil_moisture,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Indicators",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 20,
                              children: [
                                StatusIndicator(
                                  title: "Fire Sensor",
                                  isActive:
                                      (_sensorData['fire_sensor'] ?? 0.0) > 403,
                                ),
                                StatusIndicator(
                                  title: "Irrigation",
                                  isActive:
                                      (_sensorData['irrigation'] ?? 0.0) > 2000,
                                ),
                                StatusIndicator(
                                  title: "Cattle Sensor",
                                  isActive:
                                      (_sensorData['cattle_sensor'] ?? 0.0) >
                                          200,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 6,
                          semanticsLabel: "Loading sensor data...",
                        ),
                      ),
      ),
    );
  }
}
