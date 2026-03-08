import 'package:equatable/equatable.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';

enum PaymentStateStatus {
  initial,
  loading,
  loaded,
  initiated,
  verified,
  error,
}

class PaymentState extends Equatable {
  final PaymentStateStatus status;
  final List<PaymentEntity> payments;
  final PaymentEntity? selectedPayment;
  final Map<String, dynamic>? paymentPayload;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentStateStatus.initial,
    this.payments = const <PaymentEntity>[],
    this.selectedPayment,
    this.paymentPayload,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentStateStatus? status,
    List<PaymentEntity>? payments,
    PaymentEntity? selectedPayment,
    Map<String, dynamic>? paymentPayload,
    String? errorMessage,
    bool clearSelectedPayment = false,
    bool clearPaymentPayload = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      selectedPayment: clearSelectedPayment
          ? null
          : (selectedPayment ?? this.selectedPayment),
      paymentPayload: clearPaymentPayload
          ? null
          : (paymentPayload ?? this.paymentPayload),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    payments,
    selectedPayment,
    paymentPayload,
    errorMessage,
  ];
}
