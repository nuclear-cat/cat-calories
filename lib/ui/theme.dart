import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      cardTheme: CardTheme(
        // elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.white,
      ),
      textTheme: TextTheme(),
      accentColor: Colors.cyan[600],
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
