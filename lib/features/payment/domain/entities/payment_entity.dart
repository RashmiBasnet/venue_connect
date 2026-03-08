import 'package:equatable/equatable.dart';

enum PaymentRecordStatus { pending, completed, failed, refunded }

enum PaymentMethod { khalti }

class PaymentEntity extends Equatable {
  final String? paymentId;
  final String userId;
  final String bookingId;

  final int amount;

  final PaymentRecordStatus status;
  final PaymentMethod paymentMethod;

  final String? transactionId;
  final String? pidx;
  final String? paymentUrl;

  final Map<String, dynamic>? metadata;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentEntity({
    this.paymentId,
    required this.userId,
    required this.bookingId,
    required this.amount,
    this.status = PaymentRecordStatus.pending,
    this.paymentMethod = PaymentMethod.khalti,
    this.transactionId,
    this.pidx,
    this.paymentUrl,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    paymentId,
    userId,
    bookingId,
    amount,
    status,
    paymentMethod,
    transactionId,
    pidx,
    paymentUrl,
    metadata,
    createdAt,
    updatedAt,
  ];
}
