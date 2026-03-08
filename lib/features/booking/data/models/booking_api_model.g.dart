// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingUserApiModel _$BookingUserApiModelFromJson(Map<String, dynamic> json) =>
    BookingUserApiModel(
      userId: json['_id'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$BookingUserApiModelToJson(
        BookingUserApiModel instance) =>
    <String, dynamic>{
      '_id': instance.userId,
      'fullName': instance.fullName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'profilePicture': instance.profilePicture,
    };

BookingApiModel _$BookingApiModelFromJson(Map<String, dynamic> json) =>
    BookingApiModel(
      bookingId: json['_id'] as String?,
      venueRef: json['venueId'],
      packageRef: json['packageId'],
      bookedByRef: json['bookedBy'],
      eventDate: DateTime.parse(json['eventDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      guests: (json['guests'] as num).toInt(),
      pricePerPlate: (json['pricePerPlate'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] == null
          ? BookingStatus.pending
          : _bookingStatusFromJson(json['status'] as String?),
      paymentStatus: json['paymentStatus'] == null
          ? PaymentStatus.unpaid
          : _paymentStatusFromJson(json['paymentStatus'] as String?),
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String?,
      note: json['note'] as String?,
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BookingApiModelToJson(BookingApiModel instance) =>
    <String, dynamic>{
      '_id': instance.bookingId,
      'venueId': instance.venueRef,
      'packageId': instance.packageRef,
      'bookedBy': instance.bookedByRef,
      'eventDate': instance.eventDate.toIso8601String(),
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'guests': instance.guests,
      'pricePerPlate': instance.pricePerPlate,
      'totalPrice': instance.totalPrice,
      'status': _bookingStatusToJson(instance.status),
      'paymentStatus': _paymentStatusToJson(instance.paymentStatus),
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'note': instance.note,
      'extras': instance.extras,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
