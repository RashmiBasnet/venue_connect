import 'dart:io';

import 'package:venue_connect/features/auth/data/models/user_api_model.dart';
import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';

abstract interface class IUserLocalDatasource {
  Future<UserHiveModel> register(UserHiveModel model);
  Future<UserHiveModel?> login(String email, String password);
  Future<UserHiveModel?> getCurrentUser();
  Future<bool> logout();

  // get Email exists
  Future<bool> isEmailExists(String email);
}

abstract interface class IUserRemoteDatabase {
  Future<UserApiModel> register(UserApiModel model);
  Future<UserApiModel?> login(String email, String password);
  Future<UserApiModel?> getCurrentUser();
  Future<bool> logout();

  // get Email exists
  Future<bool> isEmailExists(String email);

  Future<String?> uploadProfilePicture(File image);
}
