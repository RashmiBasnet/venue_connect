import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/services/connectivity/network_info.dart';
import 'package:venue_connect/features/auth/data/datasources/local/user_local_datasource.dart';
import 'package:venue_connect/features/auth/data/datasources/remote/user_remote_datasource.dart';
import 'package:venue_connect/features/auth/data/datasources/user_datasource.dart';
import 'package:venue_connect/features/auth/data/models/user_api_model.dart';
import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    userLocalDatasource: ref.read(userLocalDatasourceProvider),
    userRemoteDatasource: ref.read(userRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class UserRepository implements IUserRepository {
  final IUserLocalDatasource _userLocalDatasource;
  final IUserRemoteDatabase _userRemoteDatabase;
  final NetworkInfo _networkInfo;
  UserRepository({
    required IUserLocalDatasource userLocalDatasource,
    required IUserRemoteDatabase userRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _userLocalDatasource = userLocalDatasource,
       _userRemoteDatabase = userRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _userRemoteDatabase.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return Left(ApiFailure(message: "Invalid Credential"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Login Failed",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _userLocalDatasource.login(email, password);
        if (user != null) {
          final entity = user.toEntity();
          return Right(entity);
        }
        return Left(LocalDatabaseFailure(message: "Invalid email or password"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _userLocalDatasource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Logout failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(UserEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = UserApiModel.fromEntity(entity);
        await _userRemoteDatabase.register(apiModel);
        return Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Registration Failed",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final existingUser = await _userLocalDatasource.isEmailExists(
          entity.email,
        );
        if (!existingUser) {
          return const Left(
            LocalDatabaseFailure(message: "Email already exists"),
          );
        }
        final userModel = UserHiveModel(
          userId: entity.userId,
          fullName: entity.fullName,
          email: entity.email,
          password: entity.password,
        );
        await _userLocalDatasource.register(userModel);
        return Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
