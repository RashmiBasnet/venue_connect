import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';
import 'package:venue_connect/features/payment/domain/usecases/get_payment_by_booking_id_usecase.dart';
import 'package:venue_connect/features/payment/domain/usecases/get_user_payments_usecase.dart';
import 'package:venue_connect/features/payment/domain/usecases/initiate_khalti_payment_usecase.dart';
import 'package:venue_connect/features/payment/domain/usecases/verify_khalti_payment_usecase.dart';
import 'package:venue_connect/features/payment/presentation/state/payment_state.dart';

final paymentViewmodelProvider =
    NotifierProvider<PaymentViewmodel, PaymentState>(() => PaymentViewmodel());

class PaymentViewmodel extends Notifier<PaymentState> {
  late final InitiateKhaltiPaymentUsecase _initiateKhaltiPaymentUsecase;
  late final VerifyKhaltiPaymentUsecase _verifyKhaltiPaymentUsecase;
  late final GetUserPaymentsUsecase _getUserPaymentsUsecase;
  late final GetPaymentByBookingIdUsecase _getPaymentByBookingIdUsecase;

  @override
  PaymentState build() {
    _initiateKhaltiPaymentUsecase = ref.read(
      initiateKhaltiPaymentUsecaseProvider,
    );
    _verifyKhaltiPaymentUsecase = ref.read(verifyKhaltiPaymentUsecaseProvider);
    _getUserPaymentsUsecase = ref.read(getUserPaymentsUsecaseProvider);
    _getPaymentByBookingIdUsecase = ref.read(
      getPaymentByBookingIdUsecaseProvider,
    );

    return const PaymentState();
  }

  Future<void> initiateKhaltiPayment({
    required String bookingId,
    required int amount,
    required String returnUrl,
  }) async {
    state = state.copyWith(
      status: PaymentStateStatus.loading,
      errorMessage: null,
      clearPaymentPayload: true,
    );

    final result = await _initiateKhaltiPaymentUsecase(
      InitiateKhaltiPaymentUsecaseParams(
        bookingId: bookingId,
        amount: amount,
        returnUrl: returnUrl,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (payload) {
        state = state.copyWith(
          status: PaymentStateStatus.initiated,
          paymentPayload: payload,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> verifyKhaltiPayment({
    required String bookingId,
    required String pidx,
  }) async {
    state = state.copyWith(
      status: PaymentStateStatus.loading,
      errorMessage: null,
      clearPaymentPayload: true,
    );

    final result = await _verifyKhaltiPaymentUsecase(
      VerifyKhaltiPaymentUsecaseParams(bookingId: bookingId, pidx: pidx),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (payload) {
        state = state.copyWith(
          status: PaymentStateStatus.verified,
          paymentPayload: payload,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getUserPayments({
    int? page,
    int? size,
    PaymentRecordStatus? status,
  }) async {
    state = state.copyWith(
      status: PaymentStateStatus.loading,
      errorMessage: null,
    );

    final result = await _getUserPaymentsUsecase(
      GetUserPaymentsUsecaseParams(page: page, size: size, status: status),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (payments) {
        state = state.copyWith(
          status: PaymentStateStatus.loaded,
          payments: payments,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getPaymentByBookingId(String bookingId) async {
    state = state.copyWith(
      status: PaymentStateStatus.loading,
      errorMessage: null,
    );

    final result = await _getPaymentByBookingIdUsecase(
      GetPaymentByBookingIdUsecaseParams(bookingId: bookingId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (payment) {
        state = state.copyWith(
          status: PaymentStateStatus.loaded,
          selectedPayment: payment,
          errorMessage: null,
        );
      },
    );
  }

  void clearSelectedPayment() {
    state = state.copyWith(clearSelectedPayment: true, errorMessage: null);
  }

  void clearPaymentPayload() {
    state = state.copyWith(clearPaymentPayload: true, errorMessage: null);
  }
}
