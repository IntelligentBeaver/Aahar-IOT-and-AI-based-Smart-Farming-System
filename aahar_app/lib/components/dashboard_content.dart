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
  File? _image;
  final _picker = ImagePicker();

  pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {
        uploadImage();
      });
    }
  }

  // Function to upload the image to the server
  Future<void> uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString("accessToken") ?? '';
    if (_image == null) {
      print("No image selected");
      return print("No Image Selected");
    }
    final _imageUrl = imageUrl;

    // Navigate to ResponsePage with the responseFuture
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponsePage(
          responseFuture: _uploadImageToServer(_image!, _imageUrl, accessToken),
        ),
      ),
    );
  }

  Future<String> _uploadImageToServer(
      File image, String url, String accessToken) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'cropImage',
        image.path,
      ));
      request.headers['Authorization'] = 'Bearer $accessToken';

      var response = await request.send();

      if (response.statusCode == 200) {
        // Return the response body
        return await response.stream.bytesToString();
      } else {
        // Handle error and return status code with message
        return "Failed to upload image. Status Code: ${response.statusCode}";
      }
    } catch (e) {
      return "Error uploading image: $e";
    }
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
        child: Stack(
          children: [
            Column(
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
                const SizedBox(height: 20),
                const Text(
                  "Soil Health",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                LiquidProgress(
                    label: "Soil Moisture",
                    value: soilMoisture // Round to 1 decimal place
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
                        isActive: (_sensorData['irrigation'] ?? 0.0) > 3900,
                      ),
                      StatusIndicator(
                        title: "Cattle Sensor",
                        isActive: (_sensorData['cattle_sensor'] ?? 0.0) < 15,
                      ),
                    ],
                  ),
                ),
                if (_connectionFailed)
                  Center(
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
                  ),
              ],
            ),
            if (_isLoading)
              Center(
                child: Positioned(
                  top: 16,
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white,
                    strokeWidth: 6,
                    semanticsLabel: "Connecting to the server...",
                  ),
                ),
              ),
            Positioned(
              bottom: 5,
              right: 5,
              child: FloatingActionButton(
                elevation: 3,
                child: Icon(Icons.camera_alt_rounded),
                onPressed: () {
                  pickImage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
