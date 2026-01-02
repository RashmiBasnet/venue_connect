import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';

abstract interface class IUserDatasource {
  Future<bool> register(UserHiveModel model);
  Future<UserHiveModel?> login(String email, String password);
  Future<UserHiveModel?> getCurrentUser();
  Future<bool> logout();

  // get Email exists
  Future<bool> isEmailExists(String email);
}