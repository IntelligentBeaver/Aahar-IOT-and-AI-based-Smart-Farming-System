import 'package:aahar_app/pages/login_page.dart';
import 'package:aahar_app/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aahar_app/pages/dashboard_page.dart';
import 'package:aahar_app/pages/sign_up_page.dart';
import 'package:aahar_app/pages/wrapper.dart';
import 'package:aahar_app/providers/control_provider.dart';
import 'package:aahar_app/providers/control_state.dart';
import 'package:aahar_app/providers/sensor_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Make sure widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SensorDataProvider()),
      ChangeNotifierProvider(create: (context) => ControlState()),
      ChangeNotifierProvider(create: (context) => ControlProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MyApp(isLoggedIn: isLoggedIn), // Pass login state to MyApp
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aahar App',
      themeMode: ThemeMode.dark,
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      home: widget.isLoggedIn ? const DashboardPage() : const LoginPage(),
      routes: {
        '/dashboard_page': (context) => const DashboardPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
