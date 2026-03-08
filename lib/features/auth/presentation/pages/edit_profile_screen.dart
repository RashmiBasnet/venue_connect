import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/core/utils/snackbar_utils.dart';
import 'package:venue_connect/core/widgets/my_textform_field.dart';
import 'package:venue_connect/features/auth/presentation/view_model/user_viewmodel.dart';

import '../../../../app/app.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(userSessionServiceProvider);
    _nameController.text = session.getCurrentUserFullName() ?? '';
    _emailController.text = session.getCurrentUserEmail() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final ok = await ref
        .read(userViewmodelProvider.notifier)
        .updateProfile(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      SnackbarUtils.showSuccess(context, 'Profile updated successfully');
      Navigator.pop(context);
      return;
    }

    final error = ref.read(userViewmodelProvider).errorMessage;
    SnackbarUtils.showError(context, error ?? 'Failed to update profile');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
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
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 480 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontFamily: 'Poppins SemiBold',
                          fontSize: 28,
                          color: kPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update your personal information.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            MyTextFormField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              controller: _nameController,
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (value.trim().length < 2) {
                                  return 'Full name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            MyTextFormField(
                              label: 'Email Address',
                              hint: 'Your email address',
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccentGold,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontFamily: 'Poppins Medium',
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
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
