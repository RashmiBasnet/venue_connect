import 'package:flutter/material.dart';
import 'package:venue_connect/screen/splash_screen.dart';

// your colors
const kPrimaryDark = Color(0xFF233041);
const kAccentGold  = Color(0xFFAE8E54);
const kSoftNeutral = Color(0xFFC4B6AB);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VenueConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryDark,
        scaffoldBackgroundColor: Colors.white,
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
      ),
      home: const SplashScreen(),
    );
  }
}
