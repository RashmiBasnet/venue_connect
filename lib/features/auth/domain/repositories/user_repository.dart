import 'package:dartz/dartz.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';

abstract interface class IUserRepository {
  Future<Either<Failure, bool>> register(UserEntity entity);
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
}