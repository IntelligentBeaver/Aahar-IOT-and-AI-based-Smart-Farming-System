import 'package:flutter/material.dart';

final ThemeData darktheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.lightGreenAccent,
    brightness: Brightness.dark,
  ),
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.lightGreen,
  ),
  // inputDecorationTheme: InputDecorationTheme(
  //   border: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(12),
  //     borderSide: BorderSide(color: Colors.grey.shade400),
  //   ),
  //   contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  //   enabledBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(12),
  //     borderSide: BorderSide(color: Colors.grey.shade400),
  //   ),
  //   focusedBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(12),
  //     borderSide: BorderSide(width: 2),
  //   ),
  // ),
);
