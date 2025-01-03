import 'package:aahar_app/common/theme.dart';
import 'package:aahar_app/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '';
import 'package:aahar_app/pages/dashboard_page.dart';
import 'package:aahar_app/pages/sign_up_page.dart';
import 'package:aahar_app/pages/wrapper.dart';
import 'package:aahar_app/providers/control_provider.dart';
import 'package:aahar_app/providers/control_state.dart';
import 'package:aahar_app/providers/sensor_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) {
          SensorDataProvider();
        },
      ),
      ChangeNotifierProvider(
        create: (context) => ControlState(),
      ),
      ChangeNotifierProvider(
        create: (context) => ControlProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en'); // Default language

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aahar App',
      locale: _locale,
      themeMode: ThemeMode.dark,
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      supportedLocales: [
        const Locale('en'),
        const Locale('hi'),
        const Locale('ne'),
      ],
      localizationsDelegates: [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Wrapper(),
      routes: {
        '/dashboard_page': (context) => const DashboardPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
