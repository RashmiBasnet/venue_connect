import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/payment/data/repositories/payment_repository.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';
import 'package:venue_connect/features/payment/domain/repositories/payment_repository.dart';

class GetUserPaymentsUsecaseParams extends Equatable {
  final int? page;
  final int? size;
  final PaymentRecordStatus? status;

  const GetUserPaymentsUsecaseParams({this.page, this.size, this.status});

  @override
  List<Object?> get props => [page, size, status];
}

final getUserPaymentsUsecaseProvider = Provider<GetUserPaymentsUsecase>((ref) {
  return GetUserPaymentsUsecase(
    paymentRepository: ref.read(paymentRepositoryProvider),
  );
});

class GetUserPaymentsUsecase
    implements
        UsecaseWithParams<List<PaymentEntity>, GetUserPaymentsUsecaseParams> {
  final IPaymentRepository _paymentRepository;

  GetUserPaymentsUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failure, List<PaymentEntity>>> call(
    GetUserPaymentsUsecaseParams params,
  ) {
    return _paymentRepository.getUserPayments(
      page: params.page,
      size: params.size,
      status: params.status,
    );
  }
}
