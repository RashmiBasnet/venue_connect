import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/services/connectivity/network_info.dart';
import 'package:venue_connect/features/package/data/datasources/local/package_local_datasource.dart';
import 'package:venue_connect/features/package/data/datasources/package_datasource.dart';
import 'package:venue_connect/features/package/data/datasources/remote/package_remote_datasource.dart';
import 'package:venue_connect/features/package/data/models/package_hive_model.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';

final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return PackageRepository(
    packageLocalDatasource: ref.read(packageLocalDatasourceProvider),
    packageRemoteDatasource: ref.read(packageRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class PackageRepository implements IPackageRepository {
  static const int _packageCacheLimit = 5;

  final IPackageLocalDatasource _packageLocalDatasource;
  final IPackageRemoteDatasource _packageRemoteDatasource;
  final NetworkInfo _networkInfo;

  PackageRepository({
    required IPackageLocalDatasource packageLocalDatasource,
    required IPackageRemoteDatasource packageRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _packageLocalDatasource = packageLocalDatasource,
       _packageRemoteDatasource = packageRemoteDatasource,
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

        final entities = apiModels.map((model) => model.toEntity()).toList();
        final hiveModels = PackageHiveModel.fromApiModelList(apiModels);

        await _packageLocalDatasource.cachePackages(
          hiveModels,
          amount: _packageCacheLimit,
        );

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
      final cachedPackages = await _packageLocalDatasource.getAllPackages(
        amount: size,
      );
      if (cachedPackages.isNotEmpty) {
        final entities = cachedPackages
            .map((model) => model.toEntity())
            .toList();
        return Right(entities);
      }

      return Left(
        ApiFailure(message: 'No Internet Connection and no cached data'),
      );
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
      final cachedPackage = await _packageLocalDatasource.getPackageById(
        packageId,
      );
      if (cachedPackage != null) {
        return Right(cachedPackage.toEntity());
      }

      return Left(
        ApiFailure(message: 'No Internet Connection and no cached data'),
      );
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
        final entities = apiModels.map((model) => model.toEntity()).toList();

        final hiveModels = PackageHiveModel.fromApiModelList(apiModels);
        if (hiveModels.isNotEmpty) {
          final existing = await _packageLocalDatasource.getAllPackages();
          final merged = <String, PackageHiveModel>{
            for (final pkg in existing)
              if ((pkg.packageId ?? '').trim().isNotEmpty) pkg.packageId!: pkg,
            for (final pkg in hiveModels)
              if ((pkg.packageId ?? '').trim().isNotEmpty) pkg.packageId!: pkg,
          };

          await _packageLocalDatasource.cachePackages(
            merged.values.toList(),
            amount: _packageCacheLimit,
          );
        }

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
      final cachedPackages = await _packageLocalDatasource.getPackagesByVenueId(
        venueId,
      );
      if (cachedPackages.isNotEmpty) {
        final entities = cachedPackages
            .map((model) => model.toEntity())
            .toList();
        return Right(entities);
      }

      return Left(
        ApiFailure(message: 'No Internet Connection and no cached data'),
      );
    }
  }
}
