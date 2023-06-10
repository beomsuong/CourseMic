import 'package:capston/palette.dart';
import 'package:flutter/material.dart';

final ButtonStyle buttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Palette.pastelPurple),
    elevation: MaterialStateProperty.all(0.0),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Palette.pastelPurple))));

ButtonStyle colorButtonStyle(Color color) {
  return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(color),
      elevation: MaterialStateProperty.all(0.0),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(color: color))));
}
