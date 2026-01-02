import 'package:flutter/material.dart';
import 'package:venue_connect/core/widgets/social_button.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen_layout.dart';
import 'package:venue_connect/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:venue_connect/core/widgets/my_textform_field.dart';
import '../../../../app/app.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomScreenLayout()),
      );
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top Right Image (responsive)
            Positioned(
              top: isTablet ? -120 : -135,
              right: isTablet ? -160 : -210,
              child: Transform.rotate(
                angle: -0.05,
                child: Image.asset(
                  'assets/images/image-2.png',
                  width: isTablet ? screenWidth * 0.6 : 580,
                  height: isTablet ? screenWidth * 0.6 : 580,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main Content (top aligned, responsive width)
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 480 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back arrow
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OnBoardingScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: "Poppins SemiBold",
                          fontSize: 32,
                          color: kPrimaryDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Welcome back!\nPlease login to continue",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email field
                            MyTextFormField(
                              label: "Email Address",
                              hint: "Your email address",
                              controller: _emailController,
                              errorMessage: "Email is required",
                              icon: Icons.email_outlined,
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            MyTextFormField(
                              label: "Password",
                              hint: "Enter your password",
                              controller: _passwordController,
                              errorMessage: "Password is required",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            const SizedBox(height: 30),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccentGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontFamily: "Poppins Medium",
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Forgot password
                            Center(
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kAccentGold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Or Continue with Social Accounts
                            const Center(
                              child: Text(
                                "Or Continue with Social Accounts",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Social buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SocialButton(icon: Icons.g_mobiledata),
                                SocialButton(icon: Icons.facebook),
                                SocialButton(icon: Icons.apple),
                                SocialButton(icon: Icons.alternate_email),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Bottom "Create Now"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don’t have an account? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _goToRegister,
                                  child: const Text(
                                    "Create Now",
                                    style: TextStyle(
                                      fontFamily: "Poppins SemiBold",
                                      fontSize: 14,
                                      color: kAccentGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
