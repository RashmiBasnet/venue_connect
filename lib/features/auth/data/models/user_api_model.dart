import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';

class UserApiModel {
  final String? userId;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;

  UserApiModel({
    this.userId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
  });

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "fullName": fullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
    };
  }

  // fromJson
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      userId: json['_id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
    );
  }

  // toEntity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  // fromEntity
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  // toEntityList
  static List<UserEntity> toEntityList(List<UserApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
