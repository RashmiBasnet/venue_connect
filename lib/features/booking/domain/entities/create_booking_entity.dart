import 'package:equatable/equatable.dart';

class CreateBookingEntity extends Equatable {
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

  const CreateBookingEntity({
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

  @override
  List<Object?> get props => [
    venueId,
    packageId,
    eventDate,
    startTime,
    endTime,
    guests,
    contactName,
    contactPhone,
    contactEmail,
    note,
    extras,
  ];
}
