import 'package:flutter/material.dart';
import 'package:venue_connect/app/theme/theme_data.dart';
import 'package:venue_connect/screen/splash_screen.dart';

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
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}
