import 'package:flutter/material.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/activity_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/package_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/venue_screen.dart';
class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  int _selectedIndex = 0;
  
  List<Widget> listBottomScreen = [
    const HomeScreen(),
    const VenueScreen(),
    const PackageScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        items: const [
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), label: 'Venue'),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: 'Package'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      
      )
    );
  }
} 