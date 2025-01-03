import 'package:flutter/material.dart';

class ThemedImage extends StatelessWidget {
  final String darkImage; // Path for dark mode image
  final String lightImage; // Path for light mode image

  const ThemedImage({
    required this.darkImage,
    required this.lightImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Image(
      image: AssetImage(isDarkMode ? darkImage : lightImage),
    );
  }
}
