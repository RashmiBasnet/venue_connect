import 'package:json_annotation/json_annotation.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';

part 'create_booking_api_model.g.dart';

@JsonSerializable()
class CreateBookingApiModel {
  final String venueId;
  final String? packageId;

  final String eventDate;
  final String startTime;
  final String endTime;

  final int guests;

  final String contactName;
  final String contactPhone;
  final String? contactEmail;

  final String? note;
  final List<String> extras;

  const CreateBookingApiModel({
    required this.venueId,
    this.packageId,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.guests,
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.note,
    this.extras = const <String>[],
  });

  factory CreateBookingApiModel.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookingApiModelToJson(this);

  CreateBookingEntity toEntity() {
    return CreateBookingEntity(
      venueId: venueId,
      packageId: packageId,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      guests: guests,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      note: note,
      extras: extras,
    );
  }

  factory CreateBookingApiModel.fromEntity(CreateBookingEntity entity) {
    return CreateBookingApiModel(
      venueId: entity.venueId,
      packageId: entity.packageId,
      eventDate: entity.eventDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      guests: entity.guests,
      contactName: entity.contactName,
      contactPhone: entity.contactPhone,
      contactEmail: entity.contactEmail,
      note: entity.note,
      extras: entity.extras,
    );
  }
}
