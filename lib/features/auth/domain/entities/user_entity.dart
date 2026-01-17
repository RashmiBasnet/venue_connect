import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;

  const UserEntity({
    this.userId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    password,
    confirmPassword,
  ];
}
