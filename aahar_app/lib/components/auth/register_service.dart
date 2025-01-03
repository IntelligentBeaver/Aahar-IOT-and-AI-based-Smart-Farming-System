import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  final String _baseUrlRegister = "http://192.168.80.187:3000/auth/register";
  Future<Map<String, dynamic>> registerUser(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrlRegister),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        // Successful registration
        return json.decode(response.body); // Return parsed response as a map
      } else {
        // Registration failed
        return {
          'success': false,
          'message': 'Failed to register',
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
}
