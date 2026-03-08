import 'package:equatable/equatable.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

enum PaymentStatus { unpaid, paid, refunded }

class BookingUserEntity extends Equatable {
  final String? userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;

  const BookingUserEntity({
    this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    phoneNumber,
    profilePicture,
  ];
}

class BookingEntity extends Equatable {
  final String? bookingId;

  final String venueId;
  final String? packageId;
  final String bookedBy;

  final VenueEntity? venue;
  final PackageEntity? package;
  final BookingUserEntity? bookedByUser;

  final DateTime eventDate;
  final String startTime;
  final String endTime;

  final int guests;

  final double pricePerPlate;
  final double totalPrice;

  final BookingStatus status;
  final PaymentStatus paymentStatus;

  final String contactName;
  final String contactPhone;
  final String? contactEmail;

  final String? note;
  final List<String> extras;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingEntity({
    this.bookingId,
    required this.venueId,
    this.packageId,
    required this.bookedBy,
    this.venue,
    this.package,
    this.bookedByUser,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.guests,
    required this.pricePerPlate,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.note,
    this.extras = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    bookingId,
    venueId,
    packageId,
    bookedBy,
    venue,
    package,
    bookedByUser,
    eventDate,
    startTime,
    endTime,
    guests,
    pricePerPlate,
    totalPrice,
    status,
    paymentStatus,
    contactName,
    contactPhone,
    contactEmail,
    note,
    extras,
    createdAt,
    updatedAt,
  ];
}
