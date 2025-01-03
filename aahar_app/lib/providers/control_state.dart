import 'package:flutter/material.dart';

class ControlState extends ChangeNotifier {
  bool isTemperatureControlOn = false;
  bool isHumidityControlOn = false;

  final List<double> temperatureData = [];
  final List<double> humidityData = [];

  void toggleTemperatureControl(bool value) {
    isTemperatureControlOn = value;
    notifyListeners();
  }

  void toggleHumidityControl(bool value) {
    isHumidityControlOn = value;
    notifyListeners();
  }

  void updateTemperature(double value) {
    temperatureData.add(value);
    notifyListeners();
  }

  void updateHumidity(double value) {
    humidityData.add(value);
    notifyListeners();
  }
}
