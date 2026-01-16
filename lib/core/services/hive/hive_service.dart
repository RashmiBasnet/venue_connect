import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:venue_connect/core/constants/hive_table_constant.dart';
import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    // find path
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }
  
  // Register Adapter
  void _registerAdapter() {
    if(!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userTable);
  }

  // Close Boxes
  Future<void> closeBoxes() async {
    await Hive.close(); 
  }

  // ===================== User Queries =====================
  Box<UserHiveModel> get _userBox => Hive.box<UserHiveModel>(HiveTableConstant.userTable);

  // Register
  Future<UserHiveModel> registerUser(UserHiveModel model) async {
    await _userBox.put(model.userId, model);
    return model;
  }

  // Login
  Future<UserHiveModel?> loginUser(String email, String password) async {
    final users = _userBox.values.where((user) => user.email == email && user.password == password);
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // Logout
  Future<void> logoutUser() async {
  }

  // Get Current User
  UserHiveModel? getCurrentUser(String userId) {
    return _userBox.get(userId);
  }

  // Check if Email Exists
  Future<bool> isEmailExists(String email) async {
    final users = _userBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}