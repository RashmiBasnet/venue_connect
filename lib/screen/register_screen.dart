import 'package:flutter/material.dart';
import '../app.dart';
import '../widgets/my_textform_field.dart';
import 'login_screen.dart';
import 'bottom_screen/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
            // Top Right Image (responsive like LoginScreen)
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
                    // prevent stretching on larger screens
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
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontFamily: "Poppins SemiBold",
                          fontSize: 28,
                          color: kPrimaryDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Sign up to get started with VenueConnect.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full name
                            MyTextFormField(
                              label: "Full Name",
                              hint: "Enter your full name",
                              controller: _nameController,
                              errorMessage: "Full name is required",
                              icon: Icons.person_outline,
                            ),

                            const SizedBox(height: 16),

                            // Email
                            MyTextFormField(
                              label: "Email Address",
                              hint: "Your email address",
                              controller: _emailController,
                              errorMessage: "Email is required",
                              icon: Icons.email_outlined,
                            ),

                            const SizedBox(height: 16),

                            // Password
                            MyTextFormField(
                              label: "Password",
                              hint: "Create a password",
                              controller: _passwordController,
                              errorMessage: "Password is required",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            const SizedBox(height: 16),

                            // Confirm Password
                            MyTextFormField(
                              label: "Confirm Password",
                              hint: "Re-enter your password",
                              controller: _confirmPasswordController,
                              errorMessage: "Confirmation is required",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            const SizedBox(height: 30),

                            // Sign Up button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccentGold,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontFamily: "Poppins Medium",
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Already have an account?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _goToLogin,
                                  child: const Text(
                                    "Login",
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
