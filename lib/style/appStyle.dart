import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  //Color palette
  static Color bgColor = Color(0xFFfffcff);
  static Color mainColor = Color(0xFF50514F);
  static Color secondaryColor = Color(0xFFF8F8FF);
  static Color tertiaryColor = Color(0xFFD9D9D9);

  static List<Color> noteColors = [
    Colors.white,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.lime,
    Colors.blue.shade900,
    Colors.pinkAccent
  ];

  //text styles
  static TextStyle mainFont = GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w500, fontSize: 25, color: mainColor);
  static TextStyle secondaryFont = GoogleFonts.nunito(
    fontSize: 14,
    color: secondaryColor,
    fontWeight: FontWeight.w400,
  );
}
