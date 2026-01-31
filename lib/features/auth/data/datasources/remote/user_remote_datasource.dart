import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_client.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/core/services/storage/token_service.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/features/auth/data/datasources/user_datasource.dart';
import 'package:venue_connect/features/auth/data/models/user_api_model.dart';

final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class UserRemoteDatasource implements IUserRemoteDatabase {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  UserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<UserApiModel?> getCurrentUser() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.userProfile,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final user = UserApiModel.fromJson(response.data["data"]);

      await _userSessionService.saveUserSession(
        userId: user.userId!,
        email: user.email,
        fullName: user.fullName,
        profilePicture: user.profilePicture,
      );

      return user;
    }
    return null;
  }

  @override
  Future<bool> isEmailExists(String email) {
    // TODO: implement isEmailExists
    throw UnimplementedError();
  }

  @override
  Future<UserApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {"email": email, "password": password},
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.userId!,
        email: user.email,
        fullName: user.fullName,
        profilePicture: user.profilePicture,
      );

      final token = response.data['token'] as String?;
      await _tokenService.saveToken(token!);

      return user;
    }
    return null;
  }

  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<UserApiModel> register(UserApiModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: model.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registerUser = UserApiModel.fromJson(data);
      return registerUser;
    }
    return model;
  }

  @override
  Future<String?> uploadProfilePicture(File image) async {
    final fileName = image.path.split("/").last;
    final formData = FormData.fromMap({
      "profile": await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final token = _tokenService.getToken();
    final response = await _apiClient.uploadFilePut(
      ApiEndpoints.uploadProfilePicture,
      formData: formData,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      final profilePicture = data["profilePicture"] as String?;

      if (profilePicture != null) {
        await _userSessionService.saveUserSession(
          userId: _userSessionService.getCurrentUserId() ?? "",
          email: _userSessionService.getCurrentUserEmail() ?? "",
          fullName: _userSessionService.getCurrentUserFullName() ?? "",
          profilePicture: profilePicture,
        );
      }

      return profilePicture;
    }

    return null;
  }
}
