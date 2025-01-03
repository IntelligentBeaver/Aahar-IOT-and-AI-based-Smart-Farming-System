import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginService {
  final String _baseUrl = "http://172.16.1.48:3000/auth/login";

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Successful login
        return _parseResponse(response.body); // Return parsed response as a map
      } else {
        // login failed
        return {
          'success': false,
          'message': 'Failed to login',
          'data': response.body
        };
      }
    } catch (error) {
      print('Error: $error');
      return {
        'success': false,
        'message': 'Error occurred',
        'data': error.toString()
      };
    }
  }

  // A helper function to parse the JSON response into a Map
  Map<String, dynamic> _parseResponse(String responseBody) {
    return json.decode(responseBody);
  }
}
