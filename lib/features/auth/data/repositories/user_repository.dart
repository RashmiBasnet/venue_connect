import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/data/datasources/local/user_local_datasource.dart';
import 'package:venue_connect/features/auth/data/datasources/user_datasource.dart';
import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(userDatasource: ref.read(userLocalDatasourceProvider));
});

class UserRepository implements IUserRepository {
  final IUserDatasource _userDatasource;
  UserRepository({required IUserDatasource userDatasource}) : _userDatasource = userDatasource;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final user = await _userDatasource.login(email, password);
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: "Invalid email or password"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async{
    try {
      final result = await _userDatasource.logout();
      if(result){
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Logout failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(UserEntity entity) async{
    try {
      final model = UserHiveModel.fromEntity(entity);
      final result = await _userDatasource.register(model);
      if(result){
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Registration failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

}