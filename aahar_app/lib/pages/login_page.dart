import 'package:aahar_app/common/custom_button.dart';
import 'package:aahar_app/common/error_dialog.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _showErrorDialog(String message) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog.adaptive(
  //         title: const Text(
  //           "Login Failed",
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Enter your $labelText',
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: Theme.of(context).inputDecorationTheme.border,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        prefixIcon: Icon(prefixIcon),
      ),
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      cursorColor: Theme.of(context).primaryColor,
    );
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      await showErrorDialog(context, 'Error', 'Please fill in both Fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final loginService = LoginService();
    final result = await loginService.loginUser(email, password);

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('accessToken', result['data']['accessToken']);
      await prefs.setBool('isLoggedIn', true);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        await showErrorDialog(context, 'Error', 'Invalid email or password');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ThemedImage(
                darkImage: "assets/Logo-t-white.png",
                lightImage: "assets/Logo-t-black.png",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.password,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(label: "Login", onPressed: _loginUser),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Color.fromARGB(255, 31, 119, 190),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
