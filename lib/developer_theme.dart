
import 'package:flutter/material.dart';

const devPink = Color(0xFFFFD6FF);
const devLilac = Color(0xFFE7C6FF);
const devPurple = Color(0xFFC8B6FF);
const devPeriwinkle = Color(0xFFB8C0FF);
const devBlue = Color(0xFFBBD0FF);

const devBackground = Color(0xFFF8F7FC);
const devText = Color(0xFF292744);
const devMuted = Color(0xFF77758D);
const devBorder = Color(0xFFEAE7F3);

ThemeData developerTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: devBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: devPurple,
      primary: devPurple,
      secondary: devPink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: devBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: devBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: devPurple, width: 1.5),
      ),
    ),
  );
}
