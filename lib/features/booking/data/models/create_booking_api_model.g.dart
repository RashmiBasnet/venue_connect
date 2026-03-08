// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingApiModel _$CreateBookingApiModelFromJson(
        Map<String, dynamic> json) =>
    CreateBookingApiModel(
      venueId: json['venueId'] as String,
      packageId: json['packageId'] as String?,
      eventDate: json['eventDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      guests: (json['guests'] as num).toInt(),
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String?,
      note: json['note'] as String?,
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CreateBookingApiModelToJson(
        CreateBookingApiModel instance) =>
    <String, dynamic>{
      'venueId': instance.venueId,
      'packageId': instance.packageId,
      'eventDate': instance.eventDate,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'guests': instance.guests,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'note': instance.note,
      'extras': instance.extras,
    };
