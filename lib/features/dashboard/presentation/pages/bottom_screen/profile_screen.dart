import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:venue_connect/app/routes/app_routes.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/core/utils/snackbar_utils.dart';
import 'package:venue_connect/features/auth/presentation/pages/login_screen.dart';
import 'package:venue_connect/features/auth/presentation/view_model/user_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery. Please enable it in your settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // code for camera
  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      await ref
          .read(userViewmodelProvider.notifier)
          .uploadProfilePicture(File(photo.path));

      if (mounted) setState(() {});
    }
  }

  // code for gallery
  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) return;

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await ref
            .read(userViewmodelProvider.notifier)
            .uploadProfilePicture(File(image.path));

        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Gallery Error: $e");
      if (mounted) {
        SnackbarUtils.showError(
          context,
          "Unable to access gallery. Please try camera instead",
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Take a photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSessionService = ref.watch(userSessionServiceProvider);

    final userName = userSessionService.getCurrentUserFullName() ?? "User";
    final profileFileName = userSessionService.getCurrentUserProfilePicture();
    final profileImageUrl =
        (profileFileName != null && profileFileName.isNotEmpty)
        ? ApiEndpoints.profilePicture(profileFileName)
        : null;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            // TOP GREY AREA (background)
            Container(
              height: 260,
              width: double.infinity,
              color: const Color(0xFFDCDCDC),
            ),

            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Grey background
                        Container(
                          height: 260,
                          width: double.infinity,
                          color: const Color(0xFFDCDCDC),
                        ),

                        // Wave
                        Positioned(
                          top: 145,
                          left: 0,
                          right: 0,
                          child: ClipPath(
                            clipper: _WaveClipper(),
                            child: Container(height: 220, color: Colors.white),
                          ),
                        ),

                        // Avatar
                        Positioned(
                          top: 90,
                          left: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickMedia,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipOval(
                                      child: (profileImageUrl != null)
                                          ? Image.network(
                                              profileImageUrl,
                                              fit: BoxFit.cover,
                                            )
                                          : CircleAvatar(
                                              radius: 70,
                                              backgroundColor: Color(
                                                0xFFCFE8F6,
                                              ),
                                              child: CircleAvatar(
                                                radius: 52,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      right: 6,
                                      bottom: 6,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 10,
                                              color: Colors.black.withOpacity(
                                                0.12,
                                              ),
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Body content
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    child: Column(
                      children: [
                        Text(userName, style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 6),
                        Text(
                          "rashmibsnt@25 | +977 9865764534",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Cards...
                        _SettingsCard(
                          children: [
                            _SettingsTile(
                              icon: Icons.edit_note,
                              title: "Edit profile information",
                              onTap: () {},
                            ),
                            _SettingsTile(
                              icon: Icons.notifications_none,
                              title: "Notifications",
                              trailingText: "ON",
                              trailingTextColor: const Color(0xFFB07C5E),
                              onTap: () {},
                            ),
                            _SettingsTile(
                              icon: Icons.translate,
                              title: "Language",
                              trailingText: "English",
                              trailingTextColor: const Color(0xFFB07C5E),
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _SettingsCard(
                          children: [
                            _SettingsTile(
                              icon: Icons.security,
                              title: "Security",
                              onTap: () {},
                            ),
                            _SettingsTile(
                              icon: Icons.palette_outlined,
                              title: "Theme",
                              trailingText: "Light mode",
                              trailingTextColor: const Color(0xFFB07C5E),
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _SettingsCard(
                          children: [
                            _SettingsTile(
                              icon: Icons.help_outline,
                              title: "Help & Support",
                              onTap: () {},
                            ),
                            _SettingsTile(
                              icon: Icons.chat_bubble_outline,
                              title: "Contact us",
                              onTap: () {},
                            ),
                            _SettingsTile(
                              icon: Icons.lock_outline,
                              title: "Privacy policy",
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: 180,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _showLogoutDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB07C5E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(userViewmodelProvider.notifier).logout();
              if (context.mounted) {
                AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- UI PARTS ----------

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final Color? trailingTextColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingTextColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showTrailing = trailingText != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showTrailing)
              Text(
                trailingText!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: trailingTextColor ?? Colors.black54,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Creates the soft wave between grey header and white body.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start top-left
    path.lineTo(0, 40);

    // Curve
    path.quadraticBezierTo(size.width * 0.35, 0, size.width * 0.65, 28);
    path.quadraticBezierTo(size.width * 0.85, 48, size.width, 24);

    // Continue to corners
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
