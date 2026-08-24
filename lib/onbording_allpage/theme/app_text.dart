import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static TextStyle _base(
    double s,
    FontWeight w, {
    Color c = AppColors.ink,
    double ls = 0,
    double? lh,
  }) => GoogleFonts.dmSans(
    fontSize: s,
    fontWeight: w,
    color: c,
    letterSpacing: ls,
    height: lh,
  );

  static final display = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.5,
    height: 1.1,
  );
  static final h1 = _base(25, FontWeight.w800, ls: -0.5);
  static final h2 = _base(18, FontWeight.w700);
  static final button = _base(15, FontWeight.w800, c: Colors.white);
  static final body = _base(14, FontWeight.w600);
  static final pill = _base(13, FontWeight.w600);
  static final sub = _base(11.5, FontWeight.w400, c: AppColors.muted, lh: 1.35);
  static final sub1 = _base(
    14.5,
    FontWeight.w400,
    c: AppColors.muted,
    lh: 1.35,
  );
  static final eyebrow = _base(
    11,
    FontWeight.w800,
    c: AppColors.muted,
    ls: 1.2,
  );
}
