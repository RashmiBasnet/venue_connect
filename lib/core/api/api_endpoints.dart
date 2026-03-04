import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.1.1';
  static const int _port = 5050;

  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // =================== Auth Endpoints ===================
  static const String userRegister = '/auth/register';
  static const String userLogin = '/auth/login';

  // =================== User Endpoints ===================
  static const String user = '/user';
  static const String userProfile = '/user/profile';
  static const String uploadProfilePicture = '/user/profile/upload';
  static const String updateUserProfile = '/user/update-profile';

  // =================== Venue Endpoints ===================
  static const String venues = '/venues';

  static String venueById(String venueId) => '$venues/$venueId';

  // =================== Package Endpoints ===================
  static const String packages = '/packages';

  static String packageById(String packageId) => '$packages/$packageId';
  static String packagesByVenueId(String venueId) => '$packages/venue/$venueId';

  static String profilePicture(String filename) =>
      '$mediaServerUrl/uploads/$filename';

  static String venueImage(String filename) =>
      '$mediaServerUrl/uploads/$filename';
}
