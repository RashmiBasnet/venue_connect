import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_client.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/features/auth/data/datasources/user_datasource.dart';
import 'package:venue_connect/features/auth/data/models/user_api_model.dart';

final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class UserRemoteDatasource implements IUserRemoteDatabase {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  UserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<UserApiModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
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
      );

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
}
