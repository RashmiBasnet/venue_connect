import 'package:flutter/material.dart';
import '../app.dart'; // MAKE SURE this file contains kAccentGold & kSoftNeutral

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
      // TODO -> Go to Login Screen
      // Navigator.pushReplacement(...)
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
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
                        Image.asset(_images[index]),

                        const SizedBox(height: 10),

                        Text(
                          _titles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _subtitles[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // DOT INDICATOR
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
                          ? kAccentGold        // changed
                          : Colors.grey[300],  // instead of kSoftNeutral
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goNext,
                  child: Text(
                    _currentPage == 2 ? "Get Started" : "Next",
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
