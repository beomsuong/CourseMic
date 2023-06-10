import 'package:flutter/material.dart';

class Palette {
  static const Color iconColor = Color(0xFFB6C7D1);
  static const Color activeColor = Color(0xFF09126C);
  static const Color textColor1 = Color(0XFFA7BCC7);
  static const Color textColor2 = Color(0XFF9BB3C0);
  static const Color facebookColor = Color(0xFF3B5999);
  static const Color googleColor = Color.fromARGB(255, 170, 46, 174);
  static const Color backgroundColor = Color(0xFFECF3F9);

  // GrayScale
  static const Color lightBlack = Color(0xFF2B2626);
  static const Color lightGray = Color(0xFFE9E9E9);
  static const Color transparencylightGray = Color.fromARGB(200, 233, 233, 233);
  static const Color darkGray = Color(0xFF8F8F8F);
  static const Color toastGray = Color(0xFF505050);

  // Pastel
  static const int _primaryValue = 0xFF763CF7;
  static const Color pastelPurple = Color(_primaryValue);
  static const Color pastelAqua = Color(0xFF8EF2EC);
  static const Color pastelBlue = Color(0xFF75C6FF);
  static const Color pastelPink = Color(0xFFCA7EFF);

  static const Color brightBlue = Color(0xFF473cf7);
  static const Color brightRed = Color(0xFFf7473c);
  static const Color brightViolet = Color(0xFFa53cf7);

  static const Color pastelWarning = Color(0xFFb78700);
  static const Color pastelYellow = Color(0xFFFFD355);
  static const Color pastelError = Color(0xFFff7e55);
  static const Color pastelBlack = Color(0xFF403000);

  static const Color pastelRed = Color(0xFFf7763c);

  static const MaterialColor primary = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFab87fa),
      100: Color(0xFFab87fa),
      200: Color(0xFF9e75f9),
      300: Color(0xFF9062f9),
      400: Color(0xFF834ff8),
      500: Color(_primaryValue),
      600: Color(0xFF6929f6),
      700: Color(0xFF5c16f5),
      800: Color(0xFF510aee),
      900: Color(0xFF4a09dc),
    },
  );
}
