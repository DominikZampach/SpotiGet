import 'package:flutter/material.dart';

class Consts {
  static const String apiUrl = "http://127.0.0.1:5050/api";

  static const Color primary = Color.fromRGBO(29, 185, 84, 1);
  static const Color secondary = Color.fromRGBO(179, 179, 179, 1);
  static const Color background = Color.fromRGBO(18, 18, 18, 1);
  static const Color surface = Color.fromRGBO(24, 24, 24, 1);
  static const Color secondarySurface = Color.fromRGBO(40, 40, 40, 1);
  static const Color white = Colors.white;

  static double h1 = 60;
  static double normal = 22;
  static double smaller = 18;

  //! Přepsat
  static double h1Mobile = 40;
  static double normalMobile = 25;
  static double smallerMobile = 20;

  static double mobileScreenWidth = 600;

  static bool isMobile(double width) {
    if (width < Consts.mobileScreenWidth) {
      return true;
    } else {
      return false;
    }
  }

  static ThemeData getThemeData(BuildContext context) {
    bool isMobile = Consts.isMobile(MediaQuery.of(context).size.width);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: surface,
        onPrimary: white,
        onSurface: white,
        primary: primary,
        secondary: secondary,
      ),
      scaffoldBackgroundColor: background,

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: isMobile ? h1Mobile : h1,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        bodyLarge: TextStyle(
          fontSize: isMobile ? normalMobile : normal,
          color: white,
        ),
        bodyMedium: TextStyle(
          fontSize: isMobile ? smallerMobile : smaller,
          color: secondary,
        ),
      ),
    );
  }
}
