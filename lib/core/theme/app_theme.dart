import 'package:flutter/material.dart';

const bg = Color(0xFF07131F);
const surface = Color(0xFF102333);
const surface2 = Color(0xFF172D40);
const mint = Color(0xFFB7F397);
const muted = Color(0xFF8DA3B5);
const readingText = Color(0xFFE8EEF2);

const readingTextStyle = TextStyle(
  fontFamily: 'PantomReading',
  fontSize: 17,
  height: 1.6,
  letterSpacing: 0,
  fontWeight: FontWeight.w400,
  color: readingText,
);

ThemeData buildAppTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        brightness: Brightness.dark,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: muted),
        prefixIconColor: muted,
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        bodyMedium: TextStyle(fontSize: 15, color: readingText),
      ),
    );
