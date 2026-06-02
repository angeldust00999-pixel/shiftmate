import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color navy = Color(0xFF1B2A4A);
  static const Color navyDark = Color(0xFF0A1628);
  static const Color cream = Color(0xFFF8F6F2);
  static const Color green = Color(0xFF2ECC71);
  static const Color brown = Color(0xFF8B5E3C);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: cream,
    primaryColor: navy,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}