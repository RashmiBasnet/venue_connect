import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/payment/data/repositories/payment_repository.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';
import 'package:venue_connect/features/payment/domain/repositories/payment_repository.dart';

class GetPaymentByBookingIdUsecaseParams extends Equatable {
  final String bookingId;

  const GetPaymentByBookingIdUsecaseParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

final getPaymentByBookingIdUsecaseProvider =
    Provider<GetPaymentByBookingIdUsecase>((ref) {
      return GetPaymentByBookingIdUsecase(
        paymentRepository: ref.read(paymentRepositoryProvider),
      );
    });

class GetPaymentByBookingIdUsecase
    implements
        UsecaseWithParams<
          PaymentEntity,
          GetPaymentByBookingIdUsecaseParams
        > {
  final IPaymentRepository _paymentRepository;

  GetPaymentByBookingIdUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failure, PaymentEntity>> call(
    GetPaymentByBookingIdUsecaseParams params,
  ) {
    return _paymentRepository.getPaymentByBookingId(params.bookingId);
  }
}
