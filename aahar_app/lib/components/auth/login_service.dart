import 'package:aahar_app/components/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginService {
  final String _baseUrlLogin = baseUrlLogin;

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrlLogin),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        // ###############################################################
        // Successful Login (Send as JSON Object)
        // ###############################################################
        print(response.body);
        return _parseResponse(response.body);
      } else {
        // ###############################################################
        // Failed Login (Send as JSON Object)
        // ###############################################################
        return {
          'success': false,
          'message': 'Failed to login',
          'data': json.decode(response.body),
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
