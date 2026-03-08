import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/services/connectivity/network_info.dart';
import 'package:venue_connect/features/booking/data/datasources/local/booking_local_datasource.dart';
import 'package:venue_connect/features/booking/data/datasources/booking_datasource.dart';
import 'package:venue_connect/features/booking/data/datasources/remote/booking_remote_datasource.dart';
import 'package:venue_connect/features/booking/data/models/booking_api_model.dart';
import 'package:venue_connect/features/booking/data/models/booking_hive_model.dart';
import 'package:venue_connect/features/booking/data/models/create_booking_api_model.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';
import 'package:venue_connect/features/booking/domain/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    bookingLocalDatasource: ref.read(bookingLocalDatasourceProvider),
    bookingRemoteDatasource: ref.read(bookingRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class BookingRepository implements IBookingRepository {
  static const int _bookingCacheLimit = 30;

  final IBookingLocalDatasource _bookingLocalDatasource;
  final IBookingRemoteDatasource _bookingRemoteDatasource;
  final NetworkInfo _networkInfo;

  BookingRepository({
    required IBookingLocalDatasource bookingLocalDatasource,
    required IBookingRemoteDatasource bookingRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _bookingLocalDatasource = bookingLocalDatasource,
       _bookingRemoteDatasource = bookingRemoteDatasource,
       _networkInfo = networkInfo;

  String _extractDioErrorMessage(
    DioException exception, {
    required String fallback,
  }) {
    final data = exception.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      final preTagMatch = RegExp(
        r'<pre>(.*?)</pre>',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(data);
      final preTagMessage = preTagMatch?.group(1)?.trim();
      if (preTagMessage != null && preTagMessage.isNotEmpty) {
        return preTagMessage;
      }

      return data;
    }

    final dioMessage = exception.message;
    if (dioMessage != null && dioMessage.trim().isNotEmpty) {
      return dioMessage;
    }

    return fallback;
  }

  @override
  Future<Either<Failure, BookingEntity>> createBooking(
    CreateBookingEntity request,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final createModel = CreateBookingApiModel.fromEntity(request);
        final apiModel = await _bookingRemoteDatasource.createBooking(
          createModel,
        );
        await _bookingLocalDatasource.cacheMyBooking(
          BookingHiveModel.fromApiModel(apiModel),
        );
        return Right(apiModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: _extractDioErrorMessage(
              e,
              fallback: 'Failed to create booking',
            ),
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
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _bookingRemoteDatasource.getMyBookings();
        final entities = BookingApiModel.toEntityList(apiModels);
        final hiveModels = BookingHiveModel.fromApiModelList(apiModels);

        await _bookingLocalDatasource.cacheMyBookings(
          hiveModels,
          amount: _bookingCacheLimit,
        );
        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: _extractDioErrorMessage(
              e,
              fallback: 'Failed to fetch my bookings',
            ),
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cachedBookings = await _bookingLocalDatasource.getMyBookings();
      if (cachedBookings.isNotEmpty) {
        return Right(BookingHiveModel.toEntityList(cachedBookings));
      }

      return Left(
        ApiFailure(message: 'No Internet Connection and no cached data'),
      );
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getMyBookingById(
    String bookingId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _bookingRemoteDatasource.getMyBookingById(
          bookingId,
        );

        if (apiModel != null) {
          await _bookingLocalDatasource.cacheMyBooking(
            BookingHiveModel.fromApiModel(apiModel),
          );
          return Right(apiModel.toEntity());
        }

        return Left(ApiFailure(message: 'Booking not found'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: _extractDioErrorMessage(
              e,
              fallback: 'Failed to fetch booking',
            ),
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cachedBooking = await _bookingLocalDatasource.getMyBookingById(
        bookingId,
      );
      if (cachedBooking != null) {
        return Right(cachedBooking.toEntity());
      }

      return Left(
        ApiFailure(message: 'No Internet Connection and no cached data'),
      );
    }
  }
}
