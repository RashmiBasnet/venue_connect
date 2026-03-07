import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/payment/data/repositories/payment_repository.dart';
import 'package:venue_connect/features/payment/domain/repositories/payment_repository.dart';

class InitiateKhaltiPaymentUsecaseParams extends Equatable {
  final String bookingId;
  final int amount;
  final String returnUrl;

  const InitiateKhaltiPaymentUsecaseParams({
    required this.bookingId,
    required this.amount,
    required this.returnUrl,
  });

  @override
  List<Object?> get props => [bookingId, amount, returnUrl];
}

final initiateKhaltiPaymentUsecaseProvider =
    Provider<InitiateKhaltiPaymentUsecase>((ref) {
      return InitiateKhaltiPaymentUsecase(
        paymentRepository: ref.read(paymentRepositoryProvider),
      );
    });

class InitiateKhaltiPaymentUsecase
    implements
        UsecaseWithParams<
          Map<String, dynamic>,
          InitiateKhaltiPaymentUsecaseParams
        > {
  final IPaymentRepository _paymentRepository;

  InitiateKhaltiPaymentUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    InitiateKhaltiPaymentUsecaseParams params,
  ) {
    return _paymentRepository.initiateKhaltiPayment(
      bookingId: params.bookingId,
      amount: params.amount,
      returnUrl: params.returnUrl,
    );
  }
}
