import 'dart:convert';

import 'package:aahar_app/components/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LEDService {
  Future<Map<String, dynamic>> sendToBackend(
      List<Map<String, dynamic>> controls) async {
    // Access Token
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken') ?? '';

    final _ledStateUrl = ledStateUrl; // Replace with your API endpoint
    final response = await http.post(
      Uri.parse(_ledStateUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'action': controls[0]['state'] ? "led_turn_on" : "led_turn_off",
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      // If the server returns a success response
      return jsonDecode(response.body);
    } else {
      print(response.body);
      // If the server returns an error
      return jsonDecode(response.body);
    }
  }
}
