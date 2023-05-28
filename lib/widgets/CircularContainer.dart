import 'package:flutter/material.dart';
import 'package:capston/palette.dart';

class CircularContainer extends Container {
  CircularContainer({super.key, super.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 20,
      decoration: BoxDecoration(
        color: Palette.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: super.child,
    );
  }
}

class ShortCircularContainer extends Container {
  ShortCircularContainer({super.key, super.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        color: Palette.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: super.child,
    );
  }
}
