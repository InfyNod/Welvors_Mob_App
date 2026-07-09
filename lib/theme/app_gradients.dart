import 'package:flutter/material.dart';

class AppGradients {
  // Premium+  → soft rose
  static const premium = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFE7EC), Color(0xFFFFD3DD)],
  ); // text: Color(0xFFB23354)

  // VIP  → dark plum, gold text
  static const vip = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF2A2433), Color(0xFF191622)],
  ); // text: Color(0xFFFFD96B)

  // VIP Elite  → gold
  static const elite = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFD96B), Color(0xFFE8A53D)],
  ); // text: Color(0xFF5A3D05)
}
