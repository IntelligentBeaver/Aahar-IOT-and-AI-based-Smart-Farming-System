import 'package:flutter/material.dart';

class ControlProvider with ChangeNotifier {
  double _temperature = 24;
  double _humidity = 80;

  double get temperature => _temperature;
  double get humidity => _humidity;

  final List<double> _temperatureData = [];
  final List<double> _humidityData = [];

  List<double> get temperatureData => _temperatureData;
  List<double> get humidityData => _humidityData;

  void toggleTemperatureControl() {
    notifyListeners();
  }

  void toggleHumidityControl() {
    notifyListeners();
  }

  void incrementTemperature() {
    _temperature = (_temperature + 1).clamp(0, 100);
    notifyListeners();
  }

  void decrementTemperature() {
    _temperature = (_temperature - 1).clamp(0, 100);
    notifyListeners();
  }

  void incrementHumidity() {
    _humidity = (_humidity + 1).clamp(0, 100);
    notifyListeners();
  }

  void decrementHumidity() {
    _humidity = (_humidity - 1).clamp(0, 100);
    notifyListeners();
  }

  void addTemperatureData(double value) {
    if (_temperatureData.length >= 20) {
      // Keep only the last 20 points
      _temperatureData.removeAt(0);
    }
    _temperatureData.add(value);
    notifyListeners();
  }

  void addHumidityData(double value) {
    if (_humidityData.length >= 20) {
      // Keep only the last 20 points
      _humidityData.removeAt(0);
    }
    _humidityData.add(value);
    notifyListeners();
  }
}
