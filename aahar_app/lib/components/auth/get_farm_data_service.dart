import 'dart:convert';

import 'package:aahar_app/components/secrets.dart';
import 'package:http/http.dart' as http;

class GetFarmDataService {
  Future<Map<String, dynamic>> postFarmData(
      Map<String, dynamic> data, String accessToken) async {
    final String _getFarmUrl = getFarmUrl;

    try {
      final http.Response response = await http.post(
        Uri.parse(_getFarmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(data),
      );
      print(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Exception: $e");
      // You can return an empty map or handle the exception with a throw
      return {
        "error": "An error occurred while posting data",
        "exception": e.toString(),
      };
    }
  }
}
