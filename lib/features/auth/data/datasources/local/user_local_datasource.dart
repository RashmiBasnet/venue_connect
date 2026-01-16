import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/services/hive/hive_service.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/features/auth/data/datasources/user_datasource.dart';
import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';

final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return UserLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class UserLocalDatasource implements IUserLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  UserLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<UserHiveModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      final exists = await _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<UserHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      if (user != null && user.userId != null) {
        // Save user session to SharedPreferences
        await _userSessionService.saveUserSession(
          userId: user.userId!,
          email: user.email,
          fullName: user.fullName,
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<UserHiveModel> register(UserHiveModel model) async {
    return await _hiveService.registerUser(model);
  }
}
