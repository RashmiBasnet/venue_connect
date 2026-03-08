import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/auth/data/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';

class UpdateProfileUsecaseParams extends Equatable {
  final String fullName;
  final String email;

  const UpdateProfileUsecaseParams({
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [fullName, email];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UpdateProfileUsecase(userRepository: userRepository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<UserEntity, UpdateProfileUsecaseParams> {
  final IUserRepository _userRepository;

  UpdateProfileUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileUsecaseParams params) {
    return _userRepository.updateProfile(
      fullName: params.fullName,
      email: params.email,
    );
  }
}
