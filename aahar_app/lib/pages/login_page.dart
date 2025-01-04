import 'package:aahar_app/common/themed_image.dart';
import 'package:aahar_app/components/auth/login_service.dart';
import 'package:aahar_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _showErrorDialog(BuildContext context, String data) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(
            "Login Failed",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(data),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            )
          ],
        );
      },
    );
  }
  // Track loading state

  void _submitform() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // ----------------------------------------------------------------
    // SHOW LOADING ANIMATION
    // ----------------------------------------------------------------
    setState(() {
      _isLoading = true; // Start loading
    });

    // Instantiate the NetworkService
    final networkService = LoginService();

    // Call the register function and get the result
    final result = await networkService.loginUser(email, password);

    // Handle the result (check if registration is successful)
    if (result['success']) {
      print("Login successful: ${result['message']}");
      print('Access Token: ${result['data']['accessToken']}');

      // Save login data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('accessToken', result['data']['accessToken']);
      await prefs.setBool('isLoggedIn', true);
      setState(() {
        _isLoading = false; // Stop loading
      });
      // Navigate to the home screen or next page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
        (route) => false,
      ); // This ensures all previous routes are removed);
    } else {
      // Handle errors
      _showErrorDialog(
        context,
        result['message'],
      );
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check the current theme brightness
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ThemedImage(
                  darkImage: "assets/Logo-t-white.png",
                  lightImage: "assets/Logo-t-black.png",
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // Text(
                //   'Kukhuri Kaa',
                //   style: TextStyle(
                //     fontSize: 38,
                //     fontWeight: FontWeight.w900,
                //   ),
                // ),
                // Text(
                //   'Smart Poultry Monitoring System',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.w300,
                //   ),
                // ),
                // SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: Theme.of(context).inputDecorationTheme.border,
                    focusedBorder: Theme.of(context)
                        .inputDecorationTheme
                        .focusedBorder
                        ?.copyWith(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                    enabledBorder:
                        Theme.of(context).inputDecorationTheme.enabledBorder,
                    prefixIcon: Icon(Icons.mail),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 16),
                  cursorColor: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your Password',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: Theme.of(context).inputDecorationTheme.border,
                    focusedBorder: Theme.of(context)
                        .inputDecorationTheme
                        .focusedBorder
                        ?.copyWith(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                    enabledBorder:
                        Theme.of(context).inputDecorationTheme.enabledBorder,
                    prefixIcon: Icon(Icons.password),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(fontSize: 16),
                  cursorColor: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator()) // Show loader when logging in
                    : ElevatedButton(
                        onPressed: _submitform,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 31, 119, 190),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
