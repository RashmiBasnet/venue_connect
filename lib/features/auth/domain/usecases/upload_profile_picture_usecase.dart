import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/auth/data/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';

class UploadProfilePictureParams extends Equatable {
  final File image;

  const UploadProfilePictureParams({required this.image});

  @override
  List<Object?> get props => [image];
}

final uploadProfilePictureUsecaseProvider =
    Provider<UploadProfilePictureUsecase>((ref) {
      return UploadProfilePictureUsecase(
        userRepository: ref.read(userRepositoryProvider),
      );
    });

class UploadProfilePictureUsecase
    implements UsecaseWithParams<String?, UploadProfilePictureParams> {
  final IUserRepository _userRepository;
  UploadProfilePictureUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;
  @override
  Future<Either<Failure, String?>> call(UploadProfilePictureParams param) {
    return _userRepository.uploadProfilePicture(param.image);
  }
}
