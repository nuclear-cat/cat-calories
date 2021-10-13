import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(
        // backgroundColor: Colors.red,
        toolbarTextStyle: TextStyle(fontSize: 16),
        titleTextStyle: TextStyle(fontSize: 16),
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      cardTheme: CardTheme(
        // elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.white,
      ),
      textTheme: TextTheme(),
      colorScheme: ColorScheme.light(
        primary: const Color(0xffffffff),
        surface: const Color(0xff000000),
        background: const Color(0xff000000),
        onPrimary: const Color(0xff000000),
      ),
      disabledColor: Colors.grey,
      primaryColor: Colors.white,
      primaryTextTheme: TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Ubuntu',
      buttonColor: Colors.cyan,
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
