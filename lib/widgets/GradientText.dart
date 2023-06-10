import 'package:capston/palette.dart';
import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  const GradientText({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.brightViolet,
              Palette.brightBlue,
            ],
          ).createShader(
            const Rect.fromLTWH(20.0, 0.0, 100.0, 0.0),
          ),
      ),
    );
  }
}
