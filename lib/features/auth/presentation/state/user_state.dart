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
  final bool biometricAvailable;
  final bool biometricEnabled;
  final bool biometricLoading;

  const UserState({
    this.status = UserStatus.initial,
    this.userEntity,
    this.profilePictureName,
    this.errorMessage,
    this.biometricAvailable = false,
    this.biometricEnabled = false,
    this.biometricLoading = false,
  });

  UserState copyWith({
    UserStatus? status,
    UserEntity? userEntity,
    String? profilePictureName,
    String? errorMessage,
    bool? biometricAvailable,
    bool? biometricEnabled,
    bool? biometricLoading,
    bool clearError = false,
  }) {
    return UserState(
      status: status ?? this.status,
      userEntity: userEntity ?? this.userEntity,
      profilePictureName: profilePictureName ?? this.profilePictureName,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricLoading: biometricLoading ?? this.biometricLoading,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userEntity,
    profilePictureName,
    errorMessage,
    biometricAvailable,
    biometricEnabled,
    biometricLoading,
  ];
}
