import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/auth/data/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';

class RegisterUsecaseParams extends Equatable{
  final String fullName;
  final String email;
  final String password;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

// Provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return RegisterUsecase(userRepository: userRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IUserRepository _userRepository;

  RegisterUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = UserEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
    );
    return _userRepository.register(entity);
  }
}