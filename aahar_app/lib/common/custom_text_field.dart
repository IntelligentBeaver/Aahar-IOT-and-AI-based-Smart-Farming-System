import 'package:flutter/material.dart';

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
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: Theme.of(context).inputDecorationTheme.border,
        focusedBorder: Theme.of(context)
            .inputDecorationTheme
            .focusedBorder
            ?.copyWith(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary)),
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
      ),
    );
  }
}
