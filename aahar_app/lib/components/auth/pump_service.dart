import 'dart:convert';
import 'package:aahar_app/components/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PumpService {
  Future<Map<String, dynamic>> sendDurationToBackend(
      int duration, List<Map<String, dynamic>> controls) async {
    // Access Token
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken') ?? '';
    final _pumpStateUrl = pumpStateUrl; // Replace with your API endpoint
    final response = await http.post(
      Uri.parse(_pumpStateUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'action': controls[1]['state'] ? "pump_turn_on" : "pump_turn_off",
        'time': duration,
      }),
    );

    if (response.statusCode == 200) {
      print(response);
      print(response.body);
      // If the server returns a success response
      return jsonDecode(response.body);
    } else {
      print(response);
      print(response.body);
      // If the server returns an error
      return jsonDecode(response.body);
    }
  }

  void sendPumpStateToBackend(control) {}
}
