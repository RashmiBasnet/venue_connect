import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/services/connectivity/network_info.dart';
import 'package:venue_connect/features/venue/data/datasources/remote/venue_remote_datasource.dart';
import 'package:venue_connect/features/venue/data/datasources/venue_datasource.dart';
import 'package:venue_connect/features/venue/data/models/venue_api_model.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/repositories/venue_repository.dart';

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  return VenueRepository(
    venueRemoteDatasource: ref.read(venueRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class VenueRepository implements IVenueRepository {
  final IVenueRemoteDatasource _venueRemoteDatasource;
  final NetworkInfo _networkInfo;

  VenueRepository({
    required IVenueRemoteDatasource venueRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _venueRemoteDatasource = venueRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<VenueEntity>>> getAllVenues() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _venueRemoteDatasource.getAllVenues();
        final entities = VenueApiModel.toEntityList(apiModels);
        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data?['message'] ??
                e.message ??
                'Failed to fetch venues',
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
  Future<Either<Failure, VenueEntity>> getVenueById(String venueId) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _venueRemoteDatasource.getVenueById(venueId);
        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }

        return Left(ApiFailure(message: 'Venue not found'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data?['message'] ??
                e.message ??
                'Failed to fetch venue',
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
