import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/services/connectivity/network_info.dart';
import 'package:venue_connect/features/package/data/datasources/package_datasource.dart';
import 'package:venue_connect/features/package/data/datasources/remote/package_remote_datasource.dart';
import 'package:venue_connect/features/package/data/models/package_api_model.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';

final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return PackageRepository(
    packageRemoteDatasource: ref.read(packageRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class PackageRepository implements IPackageRepository {
  final IPackageRemoteDatasource _packageRemoteDatasource;
  final NetworkInfo _networkInfo;

  PackageRepository({
    required IPackageRemoteDatasource packageRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _packageRemoteDatasource = packageRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<PackageEntity>>> getAllPackages({
    int? page,
    int? size,
    String? search,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _packageRemoteDatasource.getAllPackages(
          page: page,
          size: size,
          search: search,
        );
        final entities = PackageApiModel.toEntityList(apiModels);
        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data?['message'] ??
                e.message ??
                'Failed to fetch packages',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, PackageEntity>> getPackageById(
    String packageId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _packageRemoteDatasource.getPackageById(
          packageId,
        );
        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }

        return Left(ApiFailure(message: 'Package not found'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data?['message'] ??
                e.message ??
                'Failed to fetch package',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<PackageEntity>>> getPackagesByVenueId(
    String venueId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _packageRemoteDatasource.getPackagesByVenueId(
          venueId,
        );
        final entities = PackageApiModel.toEntityList(apiModels);
        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data?['message'] ??
                e.message ??
                'Failed to fetch packages by venue',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No Internet Connection'));
    }
  }
}
