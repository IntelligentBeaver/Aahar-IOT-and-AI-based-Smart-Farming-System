import 'package:aahar_app/pages/dashboard_page.dart';
import 'package:aahar_app/pages/login_page.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginPage());
  }
}
