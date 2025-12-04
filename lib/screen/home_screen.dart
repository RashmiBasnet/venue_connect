import 'package:flutter/material.dart';
import 'package:venue_connect/widgets/package_card.dart';
import 'package:venue_connect/widgets/venue_card.dart';
import '../app.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottom nav bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: kAccentGold,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
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
      ),

      body: SafeArea(
        child: Stack(
          children: [

            // Top right (leaf decoration)
            Positioned(
              top: -135,
              right: -210,
              child: Transform.rotate(
                angle: -0.05,
                child: Image.asset(
                  'assets/images/image-2.png', 
                  width: 580,
                  height: 580,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Whole Content
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LOGO
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo_blue.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Greeting
                    const Text(
                      "Hi, Rashmi",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryDark,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Search",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main Area(Packages + Venues)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Packages header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Packages",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryDark,
                                  ),
                                ),
                                Text(
                                  "See All",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Packages(horizontal list)
                            SizedBox(
                              height: 300,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: const [
                                  PackageCard(
                                    imagePath: 'assets/images/birthday.png',
                                    title: 'Birthday\nPackage',
                                  ),
                                  SizedBox(width: 12),
                                  PackageCard(
                                    imagePath: 'assets/images/outdoor.png',
                                    title: 'Outdoor Party\nPackage',
                                  ),
                                ],
                              ),
                            ),

                            // Dot indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _dot(true),
                                const SizedBox(width: 4),
                                _dot(false),
                                const SizedBox(width: 4),
                                _dot(false),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Venues header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Venues",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryDark,
                                  ),
                                ),
                                Text(
                                  "See All",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Venue card
                            const VenueCard(
                              imagePath: 'assets/images/lord_palace.png',
                              name: 'Lord Palace Banquet',
                              address: 'P8VC+7WJ, Tokha Rd,\nKathmandu',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dot(bool active) {
    return Container(
      width: active ? 8 : 6,
      height: active ? 8 : 6,
      decoration: BoxDecoration(
        color: active ? Colors.black87 : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
