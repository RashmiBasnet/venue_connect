import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/services/hive_service.dart';
import 'package:venue_connect/features/auth/data/datasources/user_datasource.dart';
import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';

final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return UserLocalDatasource(hiveService: hiveService);
});

class UserLocalDatasource implements IUserDatasource{
  final HiveService _hiveService;

  UserLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;


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
  Future<UserHiveModel?> login(String email, String password) async{
    try {
      final user =  await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async{
    try {
      await _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(UserHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }
  

}