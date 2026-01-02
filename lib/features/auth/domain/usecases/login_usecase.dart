import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/auth/data/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Proivder
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return LoginUsecase(userRepository: userRepository);
});

class LoginUsecase implements UsecaseWithParams<UserEntity, LoginUsecaseParams> {
  final IUserRepository _userRepository;

  LoginUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginUsecaseParams params) {
    return _userRepository.login(params.email, params.password);
  }
}