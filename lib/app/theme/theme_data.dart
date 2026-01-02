import 'package:flutter/material.dart';
import 'package:venue_connect/app/app.dart';

ThemeData getApplicationTheme() {
    return ThemeData(
      primaryColor: kPrimaryDark,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "Poppins Regular",
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFAE8E54),
        selectedLabelStyle: TextStyle(
          fontFamily: "Poppins SemiBold",
          fontSize: 15
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 15
        )
      )
    );
  }