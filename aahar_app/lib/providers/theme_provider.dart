import 'package:aahar_app/common/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData currentTheme = darkTheme;
  IconData currentIcon = Icons.sunny;

  void toggleTheme() {
    if (currentTheme == lightTheme) {
      currentTheme = darkTheme;
      currentIcon = Icons.dark_mode;
      notifyListeners();
    } else {
      currentTheme = lightTheme;
      currentIcon = Icons.sunny;
      notifyListeners();
    }
  }
}
