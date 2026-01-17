import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/auth/data/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(userRepository: ref.read(userRepositoryProvider));
});

class LogoutUsecase implements UsecaseWithoutParams<bool> {
  final IUserRepository _userRepository;

  LogoutUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _userRepository.logout();
  }
}
