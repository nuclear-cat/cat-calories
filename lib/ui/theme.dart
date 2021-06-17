import 'package:flutter/material.dart';

class CustomTheme {

  static ThemeData get lightTheme {
    return ThemeData(
      cardTheme: CardTheme(
          // elevation: 0,
          shadowColor: Colors.cyan[50]),
      textTheme: TextTheme(),
      accentColor: Colors.cyan[600],
      primaryColor: Colors.white,
      primaryTextTheme: TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: Colors.cyan[50],
      fontFamily: 'Ubuntu',
      buttonColor: Colors.cyan,
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),

        buttonColor: Colors.deepPurple,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
