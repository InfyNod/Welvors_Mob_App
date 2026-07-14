import 'package:flutter/material.dart';

class AppColors {
  static const Color pink      = Color(0xFFE85A7A); // accent
  static const Color pinkDeep  = Color(0xFFC73A5E);
  static const Color pinkSoft  = Color(0xFFFFE7EC);
  static const Color ink       = Color(0xFF1F1F1F); // primary text
  static const Color ink60     = Color(0xFF5F5C56); // secondary text
  static const Color muted     = Color(0xFF8A8680); // hint / helper
  static const Color line      = Color(0xFFECE6DC); // borders / dividers
  static const Color soft      = Color(0xFFF5F2EC); // chip / fill
  static const Color card      = Color(0xFFFFFFFF);
  static const Color canvas    = Color(0xFFFCF7F3); // HSL(30, 57%, 97%) scaffold bg
  static const Color green     = Color(0xFF2EAF6B);
  static const Color greenSoft = Color(0xFFE8F8EF);
  static const Color blue      = Color(0xFF3DA9FF);
  static const Color gold      = Color(0xFFE8A53D);

  // soft, warm elevation used on every card
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 3,  offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 4)),
  ];
}
