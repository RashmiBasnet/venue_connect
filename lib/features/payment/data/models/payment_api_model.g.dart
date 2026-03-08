// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentApiModel _$PaymentApiModelFromJson(Map<String, dynamic> json) =>
    PaymentApiModel(
      paymentId: json['_id'] as String?,
      userId: json['userId'] as String,
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toInt(),
      status: json['status'] == null
          ? PaymentRecordStatus.pending
          : _paymentStatusFromJson(json['status'] as String?),
      paymentMethod: json['paymentMethod'] == null
          ? PaymentMethod.khalti
          : _paymentMethodFromJson(json['paymentMethod'] as String?),
      transactionId: json['transactionId'] as String?,
      pidx: json['pidx'] as String?,
      paymentUrl: json['paymentUrl'] as String?,
      metadata: _metadataFromJson(json['metadata']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentApiModelToJson(PaymentApiModel instance) =>
    <String, dynamic>{
      '_id': instance.paymentId,
      'userId': instance.userId,
      'bookingId': instance.bookingId,
      'amount': instance.amount,
      'status': _paymentStatusToJson(instance.status),
      'paymentMethod': _paymentMethodToJson(instance.paymentMethod),
      'transactionId': instance.transactionId,
      'pidx': instance.pidx,
      'paymentUrl': instance.paymentUrl,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
