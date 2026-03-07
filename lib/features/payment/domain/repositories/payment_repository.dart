import 'package:dartz/dartz.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';

abstract interface class IPaymentRepository {
  Future<Either<Failure, Map<String, dynamic>>> initiateKhaltiPayment({
    required String bookingId,
    required int amount,
    required String returnUrl,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyKhaltiPayment({
    required String bookingId,
    required String pidx,
  });

  Future<Either<Failure, List<PaymentEntity>>> getUserPayments({
    int? page,
    int? size,
    PaymentRecordStatus? status,
  });

  Future<Either<Failure, PaymentEntity>> getPaymentByBookingId(String bookingId);
}
