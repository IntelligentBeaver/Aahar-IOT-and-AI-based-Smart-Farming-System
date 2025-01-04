import 'package:aahar_app/common/custom_button.dart';
import 'package:aahar_app/common/error_dialog.dart';
import 'package:aahar_app/common/themed_image.dart';
import 'package:aahar_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import '../components/auth/register_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Input validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      await showErrorDialog(context, 'Error', 'IAll fields are required');
      return;
    }
    if (password != confirmPassword) {
      await showErrorDialog(context, 'Error', 'Passwords do not match.');
      return;
    }

    // Show loading spinner
    setState(() {
      _isLoading = true;
    });

    // Call register service
    final networkService = RegisterService();
    final result = await networkService.registerUser(email, password);

    if (result['success']) {
      print("Registration successful: ${result['message']}");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
        (route) => false,
      );
    } else {
      await showErrorDialog(context, 'Error', result['message']);
    }

    // Stop loading spinner
    setState(() {
      _isLoading = false;
    });
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
              const ThemedImage(
                darkImage: "assets/Logo-t-white.png",
                lightImage: "assets/Logo-t-black.png",
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'Enter your email',
                icon: Icons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(label: "Register", onPressed: _registerUser),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
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

// Reusable CustomTextField widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: Theme.of(context).inputDecorationTheme.border,
        focusedBorder:
            Theme.of(context).inputDecorationTheme.focusedBorder?.copyWith(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
