import 'package:flutter/material.dart';

class AppColors {
  static const String apiBaseUrl = 'https://randomuser.me/api/';
  static const int resultsCount = 20;
  static const String apiUrl = '$apiBaseUrl?results=$resultsCount';
  static const Color white = Colors.white; // accent
  static const Color pink = Color(0xFFE85A7A); // accent
  static const Color pink1 = Color(0xFFE43A6A); // accent
  static const Color pinkDeep = Color(0xFFC73A5E);
  static const Color pinkSoft = Color(0xFFFFE7EC);
  static const Color ink = Color(0xFF1F1F1F); // primary text
  static const Color ink60 = Color(0xFF5F5C56); // secondary text
  static const Color muted = Color(0xFF8A8680); // hint / helper
  static const Color line = Color(0xFFECE6DC); // borders / dividers
  static const Color soft = Color(0xFFF5F2EC); // chip / fill
  static const Color card = Color(0xFFFFFFFF);
  static const Color canvas = Color(
    0xFFFCF7F3,
  ); // HSL(30, 57%, 97%) scaffold bg
  static const Color green = Color(0xFF2EAF6B);
  static const Color greenSoft = Color(0xFFE8F8EF);
  static const Color blue = Color(0xFF3DA9FF);
  static const Color gold = Color(0xFFE8A53D);

  // soft, warm elevation used on every card
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const Color background = Color(0xFFF8F4F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFE85A7A);
  static const Color primaryDark = Color(0xFFD44D6A);
  static const Color primarySoft = Color(0xFFFCE8EE);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted = Color(0xFFB5B5B5);
  static const Color border = Color(0xFFECE7E2);
  static const Color chipBg = Color(0xFFF3EEE9);
  static const Color online = Color(0xFF2FD67B);
  static const Color matchBlue = Color(0xFF4BA3FF);
  static const Color trustGreen = Color(0xFF35C97A);
  static const Color replyGold = Color(0xFFE6A83A);
  static const Color navInactive = Color(0xFF6E6E6E);
  static const Color purple = Color(0xFF9B6DFF);
  static const Color darkChip = Color(0xFF2D2D2D);
  static const Color warning = Color(0xFFFF9F43);
  static const Color shadow1 = Color(0x14000000);
  static const Color yellowborder = Color(0xfff3e2c3);
  //
  static const Color chatpinkborder = Color(0xfff6d7e1);
  static const Color chatpinkcontanersender = Color(0xffffeef2);
  static const Color colorf7dae2 = Color(0xfff7dae2);
}
