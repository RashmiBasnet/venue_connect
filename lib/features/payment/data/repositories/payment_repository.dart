import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/services/connectivity/network_info.dart';
import 'package:venue_connect/features/payment/data/datasources/payment_datasource.dart';
import 'package:venue_connect/features/payment/data/datasources/remote/payment_remote_datasource.dart';
import 'package:venue_connect/features/payment/data/models/payment_api_model.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';
import 'package:venue_connect/features/payment/domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(
    paymentRemoteDatasource: ref.read(paymentRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class PaymentRepository implements IPaymentRepository {
  final IPaymentRemoteDatasource _paymentRemoteDatasource;
  final NetworkInfo _networkInfo;

  PaymentRepository({
    required IPaymentRemoteDatasource paymentRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _paymentRemoteDatasource = paymentRemoteDatasource,
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
  Future<Either<Failure, Map<String, dynamic>>> initiateKhaltiPayment({
    required String bookingId,
    required int amount,
    required String returnUrl,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _paymentRemoteDatasource.initiateKhaltiPayment(
          bookingId: bookingId,
          amount: amount,
          returnUrl: returnUrl,
        );

        return Right(response);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: _extractDioErrorMessage(
              e,
              fallback: 'Failed to initiate payment',
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
  Future<Either<Failure, Map<String, dynamic>>> verifyKhaltiPayment({
    required String bookingId,
    required String pidx,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _paymentRemoteDatasource.verifyKhaltiPayment(
          bookingId: bookingId,
          pidx: pidx,
        );

        return Right(response);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: _extractDioErrorMessage(
              e,
              fallback: 'Failed to verify payment',
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
  Future<Either<Failure, List<PaymentEntity>>> getUserPayments({
    int? page,
    int? size,
    PaymentRecordStatus? status,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _paymentRemoteDatasource.getUserPayments(
          page: page,
          size: size,
          status: status?.name,
        );

        return Right(PaymentApiModel.toEntityList(models));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: _extractDioErrorMessage(
              e,
              fallback: 'Failed to fetch payments',
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
  Future<Either<Failure, PaymentEntity>> getPaymentByBookingId(
    String bookingId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _paymentRemoteDatasource.getPaymentByBookingId(
          bookingId,
        );

        if (model != null) {
          return Right(model.toEntity());
        }

        return Left(ApiFailure(message: 'Payment not found'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: _extractDioErrorMessage(
              e,
              fallback: 'Failed to fetch payment',
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
}
