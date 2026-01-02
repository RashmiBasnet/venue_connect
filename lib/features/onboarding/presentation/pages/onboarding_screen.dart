import 'package:flutter/material.dart';
import 'package:venue_connect/features/auth/presentation/pages/login_screen.dart';
import '../../../../app/app.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/find_your_venue.png',
    'assets/images/curated_packages.png',
    'assets/images/plan_book.png',
  ];

  final List<String> _titles = [
    "Find the Perfect Venue",
    "Choose Event Packages",
    "Book Seamlessly",
  ];

  final List<String> _subtitles = [
    "Browse venues for birthdays, weddings, outdoor parties and more.",
    "Pick curated packages offered by venues for stress-free planning.",
    "Compare options, check availability and confirm in a few taps.",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // TOP: page content (image + texts)
              Expanded(
                flex: 7,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 3,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // IMAGE
                        Flexible(
                          flex: 5,
                          child: Image.asset(
                            _images[index],
                            height: screenHeight * 0.40,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // TITLE
                        Flexible(
                          flex: 2,
                          child: Text(
                            _titles[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Poppins SemiBold",
                              fontSize: 28,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        // SUBTITLE
                        Flexible(
                          flex: 2,
                          child: Text(
                            _subtitles[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Poppins Regular",
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // BOTTOM: dots + button (fixed area)
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 16 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? kAccentGold
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goNext,
                        child: Text(
                          _currentPage == 2 ? "Get Started" : "Next",
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
