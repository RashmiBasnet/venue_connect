import 'package:equatable/equatable.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';

enum UserStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
  loaded,
}

class UserState extends Equatable {
  final UserStatus status;
  final UserEntity? userEntity;
  final String? profilePictureName;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.userEntity,
    this.profilePictureName,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    UserEntity? userEntity,
    String? profilePictureName,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      userEntity: userEntity ?? this.userEntity,
      profilePictureName: profilePictureName ?? this.profilePictureName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userEntity, errorMessage];
}
