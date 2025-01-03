// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Importing dart:async for Timer

class SensorDataProvider with ChangeNotifier {
  double _temperature = 24; // Initial temperature value
  double _humidity = 80; // Initial humidity value
  // final DatabaseReference _dbRef =
  //     FirebaseDatabase.instance.ref().child('test'); // Firebase reference

  double get temperature => _temperature;
  double get humidity => _humidity;

  SensorDataProvider() {
    _startFetchingData();
  }

  // Start fetching data from Firebase every 1 second
  void _startFetchingData() {
    // Fetch initial data
    fetchData();

    // Use Timer.periodic to fetch data every 1 second
    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  void fetchData() async {
    // final snapshot = await _dbRef.get(); // Get data from Firebase
    // if (snapshot.exists) {
    //   final data = snapshot.value as Map<dynamic, dynamic>;
    //   double temp = data['temp']?.toDouble() ?? 24;
    //   double humidity = data['humidity']?.toDouble() ?? 80;

    //   if (_temperature != temp) {
    //     _temperature = temp;
    //     notifyListeners(); // Notify listeners when data changes
    //   }
    //   if (_humidity != humidity) {
    //     _humidity = humidity;
    //     notifyListeners(); // Notify listeners when data changes
    //   }
    // }
  }
}
