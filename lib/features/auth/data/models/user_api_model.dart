import 'package:json_annotation/json_annotation.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';

part 'user_api_model.g.dart';

@JsonSerializable()
class UserApiModel {
  @JsonKey(name: "_id")
  final String? userId;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture;

  UserApiModel({
    this.userId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    this.profilePicture,
  });

  // To JSON
  Map<String, dynamic> toJson() => _$UserApiModelToJson(this);

  // fromJson
  factory UserApiModel.fromJson(Map<String, dynamic> json) =>
      _$UserApiModelFromJson(json);

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
