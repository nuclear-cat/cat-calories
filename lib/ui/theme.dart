import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      cardTheme: CardTheme(
        // elevation: 0,
        shadowColor: Colors.black26
      ),
      textTheme: TextTheme(),
      accentColor: Colors.cyan[600],
      primaryColor: Colors.white,
      primaryTextTheme: TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: Colors.blueGrey[50],
      fontFamily: 'Ubuntu',
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      ),
    );
  }
}
