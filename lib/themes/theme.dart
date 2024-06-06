import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  datePickerTheme: DatePickerThemeData(
    dividerColor: Colors.transparent,
    shadowColor: Colors.grey.shade400,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: Colors.black,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.shade700,
        ),
      ),
    ),
    todayForegroundColor: MaterialStateProperty.all(Colors.black87),
    dayOverlayColor: MaterialStateProperty.all(Colors.white60),
    dayForegroundColor: MaterialStateProperty.all(Colors.black),
    confirmButtonStyle: ElevatedButton.styleFrom(
      shadowColor: Colors.grey.shade500,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    cancelButtonStyle: ElevatedButton.styleFrom(
      shadowColor: Colors.grey.shade500,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    headerHeadlineStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    surfaceTintColor: Colors.grey.shade400,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    backgroundColor: Colors.grey.shade200,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 22,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.grey,
      shadowColor: Colors.grey.shade500,
    ),
  ),
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade300,
    primary: Colors.grey.shade200,
    secondary: Colors.grey.shade400,
    tertiary: Colors.grey.shade600,
    shadow: Colors.grey.shade500,
    inversePrimary: Colors.grey.shade900,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  datePickerTheme: DatePickerThemeData(
    dividerColor: Colors.transparent,
    surfaceTintColor: Colors.grey.shade800,
    shadowColor: Colors.grey.shade500,
    todayForegroundColor: MaterialStateProperty.all(Colors.white60),
    dayOverlayColor: MaterialStateProperty.all(Colors.black87),
    dayForegroundColor: MaterialStateProperty.all(Colors.white),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: Colors.white,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.shade400,
        ),
      ),
    ),
    confirmButtonStyle: ElevatedButton.styleFrom(
      shadowColor: Colors.grey.shade200,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    cancelButtonStyle: ElevatedButton.styleFrom(
      shadowColor: Colors.grey.shade200,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    headerHeadlineStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    backgroundColor: Colors.grey.shade800,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
    ),
  ),
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade400,
    shadow: Colors.black,
    inversePrimary: Colors.grey.shade300,
  ),
);
