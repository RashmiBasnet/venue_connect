import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/payment/data/repositories/payment_repository.dart';
import 'package:venue_connect/features/payment/domain/repositories/payment_repository.dart';

class VerifyKhaltiPaymentUsecaseParams extends Equatable {
  final String bookingId;
  final String pidx;

  const VerifyKhaltiPaymentUsecaseParams({
    required this.bookingId,
    required this.pidx,
  });

  @override
  List<Object?> get props => [bookingId, pidx];
}

final verifyKhaltiPaymentUsecaseProvider = Provider<VerifyKhaltiPaymentUsecase>(
  (ref) {
    return VerifyKhaltiPaymentUsecase(
      paymentRepository: ref.read(paymentRepositoryProvider),
    );
  },
);

class VerifyKhaltiPaymentUsecase
    implements
        UsecaseWithParams<
          Map<String, dynamic>,
          VerifyKhaltiPaymentUsecaseParams
        > {
  final IPaymentRepository _paymentRepository;

  VerifyKhaltiPaymentUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    VerifyKhaltiPaymentUsecaseParams params,
  ) {
    return _paymentRepository.verifyKhaltiPayment(
      bookingId: params.bookingId,
      pidx: params.pidx,
    );
  }
}
