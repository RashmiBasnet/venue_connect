import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/activity_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/package_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/venue_screen.dart';

class BottomScreenLayout extends ConsumerStatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  ConsumerState<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends ConsumerState<BottomScreenLayout> {
  int _selectedIndex = 0;

  final List<Widget> listBottomScreen = [
    const HomeScreen(),
    const VenueScreen(),
    const PackageScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work_outlined),
            label: 'Venue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            label: 'Package',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
