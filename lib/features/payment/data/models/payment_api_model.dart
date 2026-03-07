import 'package:json_annotation/json_annotation.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';

part 'payment_api_model.g.dart';

PaymentRecordStatus _paymentStatusFromJson(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'completed':
      return PaymentRecordStatus.completed;
    case 'failed':
      return PaymentRecordStatus.failed;
    case 'refunded':
      return PaymentRecordStatus.refunded;
    case 'pending':
    default:
      return PaymentRecordStatus.pending;
  }
}

String _paymentStatusToJson(PaymentRecordStatus value) => value.name;

PaymentMethod _paymentMethodFromJson(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'khalti':
    default:
      return PaymentMethod.khalti;
  }
}

String _paymentMethodToJson(PaymentMethod value) => value.name;

Map<String, dynamic>? _metadataFromJson(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}

@JsonSerializable()
class PaymentApiModel {
  @JsonKey(name: '_id')
  final String? paymentId;
  final String userId;
  final String bookingId;

  final int amount;

  @JsonKey(fromJson: _paymentStatusFromJson, toJson: _paymentStatusToJson)
  final PaymentRecordStatus status;

  @JsonKey(fromJson: _paymentMethodFromJson, toJson: _paymentMethodToJson)
  final PaymentMethod paymentMethod;

  final String? transactionId;
  final String? pidx;
  final String? paymentUrl;

  @JsonKey(fromJson: _metadataFromJson)
  final Map<String, dynamic>? metadata;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentApiModel({
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

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentApiModelToJson(this);

  PaymentEntity toEntity() {
    return PaymentEntity(
      paymentId: paymentId,
      userId: userId,
      bookingId: bookingId,
      amount: amount,
      status: status,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      pidx: pidx,
      paymentUrl: paymentUrl,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PaymentApiModel.fromEntity(PaymentEntity entity) {
    return PaymentApiModel(
      paymentId: entity.paymentId,
      userId: entity.userId,
      bookingId: entity.bookingId,
      amount: entity.amount,
      status: entity.status,
      paymentMethod: entity.paymentMethod,
      transactionId: entity.transactionId,
      pidx: entity.pidx,
      paymentUrl: entity.paymentUrl,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<PaymentEntity> toEntityList(List<PaymentApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
