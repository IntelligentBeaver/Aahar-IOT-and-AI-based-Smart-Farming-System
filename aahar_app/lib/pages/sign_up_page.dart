// import 'package:firebase_auth/firebase_auth.dart';
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
  // final _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void _submitForm() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ----------------------------------------------------------------
    // SHOW LOADING ANIMATION
    // ----------------------------------------------------------------
    setState(() {
      _isLoading = true; // Start loading
    });

    // Instantiate the NetworkService
    final networkService = RegisterService();

    // Call the register function and get the result
    final result = await networkService.registerUser(email, password);

    print(result);
    // Handle the result (check if registration is successful)
    if (result['success']) {
      print("Registration successful: ${result['message']}");
      print('Access Token: ${result['data']['accessToken']}');
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration failed: ${result['message']}"),
      ));
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // TextField(
                //   // controller: _fullNameController,
                //   decoration: InputDecoration(
                //     labelText: 'Full Name',
                //     prefixIcon: Icon(Icons.person),
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                // SizedBox(height: 20),
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
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your Password',
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
                SizedBox(height: 40),
                _isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator()) // Show loader when logging in
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
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
      ),
    );
  }
}
