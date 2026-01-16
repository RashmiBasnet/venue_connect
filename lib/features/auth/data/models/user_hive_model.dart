import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:venue_connect/core/constants/hive_table_constant.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? password;

  UserHiveModel({
    String? userId,
    required this.fullName,
    required this.email,
    this.password,
  }) : userId = userId ?? Uuid().v4();

  // fromEntity
  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
    );
  }

  // toEntity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: null,
    );
  }

  // toEntityList
  static List<UserEntity> toEntityList(List<UserHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
