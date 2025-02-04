import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:aahar_app/components/circular_progress.dart';
import 'package:aahar_app/components/liquid_progress.dart';
import 'package:aahar_app/components/response_page.dart';
import 'package:aahar_app/components/secrets.dart';
import 'package:aahar_app/components/status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final String _webSocketUrl = webSocketUrl;
  late WebSocketChannel _channel;
  StreamSubscription? _streamSubscription;
  Map<String, dynamic> _sensorData = {};
  bool _connectionFailed = false;
  Timer? _timeoutTimer;
  bool _isDisposed = false;
  bool _isLoading = false;
  String? _errorMessage;

  double temperature = 0.0;
  double humidity = 0.0;
  double soilMoisture = 4095.0;
  List<String> _alerts = []; // List to store alerts

  File? _image;
  final _picker = ImagePicker();

  // Function to update alerts based on sensor data
  void _updateAlerts() {
    _alerts.clear();

    // Soil Health Alert
    if (soilMoisture > 3000) {
      _alerts.add("Soil health is critical! Moisture level is too low.");
    }

    // Fire Sensor Alert
    if ((_sensorData['fire_sensor'] ?? 0.0) < 4000) {
      _alerts.add("Fire detected in the field! Immediate action required.");
    }

    // Irrigation Alert
    if ((_sensorData['irrigation'] ?? 0.0) > 3900) {
      _alerts.add("Irrigation system requires attention!");
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void setStateIfMounted(VoidCallback fn) {
    if (!_isDisposed) {
      setState(fn);
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      setStateIfMounted(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));

      _timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (_sensorData.isEmpty) {
          setStateIfMounted(() {
            _connectionFailed = true;
            _isLoading = false;
          });
          _channel.sink.close(status.normalClosure);
        }
      });

      _streamSubscription = _channel.stream.listen(
        (message) {
          _timeoutTimer?.cancel();
          setStateIfMounted(() {
            _sensorData = Map<String, dynamic>.from(jsonDecode(message));
            print(_sensorData.toString());
            temperature = (_sensorData['temperature']?.toDouble() ?? 0.0);
            humidity = (_sensorData['humidity']?.toDouble() ?? 0.0);
            soilMoisture = double.parse(
                (_sensorData['soil_moisture']?.toDouble() ?? 4095.0)
                    .toStringAsFixed(1));

            _isLoading = false;

            // Update alerts whenever sensor data changes
            _updateAlerts();
          });
        },
        onError: (error) {
          setStateIfMounted(() {
            _connectionFailed = true;
            _isLoading = false;
            _errorMessage = error.toString();
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
        _errorMessage = e.toString();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Temp and Humidity",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
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

            const Text(
              "Soil Health",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            LiquidProgress(
              label: "Soil Moisture",
              value: soilMoisture,
            ),
            const SizedBox(height: 20),
            const Text(
              "Indicators",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
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
                    isActive: (_sensorData['fire_sensor'] ?? 0.0) < 4000,
                  ),
                  StatusIndicator(
                    title: "Irrigation",
                    isActive: (_sensorData['irrigation'] ?? 0.0) == 1,
                  ),
                  StatusIndicator(
                    title: "Cattle Sensor",
                    isActive: (_sensorData['cattle_sensor'] ?? 0.0) == 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Alerts",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),

            // Display Alerts as ListTiles
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),
                    title: Text(
                      _alerts[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
