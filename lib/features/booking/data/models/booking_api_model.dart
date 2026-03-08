import 'package:json_annotation/json_annotation.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/package/data/models/package_api_model.dart';
import 'package:venue_connect/features/venue/data/models/venue_api_model.dart';

part 'booking_api_model.g.dart';

BookingStatus _bookingStatusFromJson(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'confirmed':
      return BookingStatus.confirmed;
    case 'cancelled':
      return BookingStatus.cancelled;
    case 'completed':
      return BookingStatus.completed;
    case 'pending':
    default:
      return BookingStatus.pending;
  }
}

String _bookingStatusToJson(BookingStatus status) => status.name;

PaymentStatus _paymentStatusFromJson(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'paid':
      return PaymentStatus.paid;
    case 'refunded':
      return PaymentStatus.refunded;
    case 'unpaid':
    default:
      return PaymentStatus.unpaid;
  }
}

String _paymentStatusToJson(PaymentStatus status) => status.name;

String _idFromRaw(dynamic value) {
  if (value is String) return value;
  if (value is Map<String, dynamic>) return (value['_id'] as String?) ?? '';
  return '';
}

String? _nullableIdFromRaw(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map<String, dynamic>) return value['_id'] as String?;
  return null;
}

VenueApiModel? _venueFromRaw(dynamic value) {
  if (value is! Map<String, dynamic>) return null;

  final normalized = <String, dynamic>{...value};
  normalized['name'] ??= 'Unknown venue';
  normalized['description'] ??= '';
  normalized['address'] ??= {'city': 'Kathmandu', 'country': 'Nepal'};
  normalized['images'] ??= <dynamic>[];
  normalized['pricePerPlate'] ??= 0;
  normalized['capacity'] ??= {'minGuests': 1, 'maxGuests': 1};
  normalized['amenities'] ??= <dynamic>[];
  normalized['isActive'] ??= true;

  return VenueApiModel.fromJson(normalized);
}

PackageApiModel? _packageFromRaw(dynamic value) {
  if (value is! Map<String, dynamic>) return null;

  final normalized = <String, dynamic>{...value};
  normalized['venueId'] ??= '';
  normalized['name'] ??= 'Unknown package';
  normalized['description'] ??= '';
  normalized['images'] ??= <dynamic>[];
  normalized['pricePerPlate'] ??= 0;
  normalized['inclusions'] ??= <dynamic>[];
  normalized['addOns'] ??= <dynamic>[];
  normalized['isActive'] ??= true;

  return PackageApiModel.fromJson(normalized);
}

@JsonSerializable()
class BookingUserApiModel {
  @JsonKey(name: '_id')
  final String? userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;

  BookingUserApiModel({
    this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
  });

  factory BookingUserApiModel.fromJson(Map<String, dynamic> json) =>
      _$BookingUserApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingUserApiModelToJson(this);

  BookingUserEntity toEntity() {
    return BookingUserEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
    );
  }

  factory BookingUserApiModel.fromEntity(BookingUserEntity entity) {
    return BookingUserApiModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
    );
  }
}

BookingUserApiModel? _bookedByUserFromRaw(dynamic value) {
  if (value is! Map<String, dynamic>) return null;

  final normalized = <String, dynamic>{...value};
  normalized['profilePicture'] ??= normalized['profileImage'];

  return BookingUserApiModel.fromJson(normalized);
}

@JsonSerializable(explicitToJson: true)
class BookingApiModel {
  @JsonKey(name: '_id')
  final String? bookingId;

  @JsonKey(name: 'venueId')
  final dynamic venueRef;

  @JsonKey(name: 'packageId')
  final dynamic packageRef;

  @JsonKey(name: 'bookedBy')
  final dynamic bookedByRef;

  final DateTime eventDate;
  final String startTime;
  final String endTime;

  final int guests;

  final double pricePerPlate;
  final double totalPrice;

  @JsonKey(fromJson: _bookingStatusFromJson, toJson: _bookingStatusToJson)
  final BookingStatus status;

  @JsonKey(fromJson: _paymentStatusFromJson, toJson: _paymentStatusToJson)
  final PaymentStatus paymentStatus;

  final String contactName;
  final String contactPhone;
  final String? contactEmail;

  final String? note;
  final List<String> extras;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingApiModel({
    this.bookingId,
    required this.venueRef,
    this.packageRef,
    required this.bookedByRef,
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

  factory BookingApiModel.fromJson(Map<String, dynamic> json) =>
      _$BookingApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingApiModelToJson(this);

  String get venueId => _idFromRaw(venueRef);
  String? get packageId => _nullableIdFromRaw(packageRef);
  String get bookedBy => _idFromRaw(bookedByRef);

  VenueApiModel? get venue => _venueFromRaw(venueRef);
  PackageApiModel? get package => _packageFromRaw(packageRef);
  BookingUserApiModel? get bookedByUser => _bookedByUserFromRaw(bookedByRef);

  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: bookingId,
      venueId: venueId,
      packageId: packageId,
      bookedBy: bookedBy,
      venue: venue?.toEntity(),
      package: package?.toEntity(),
      bookedByUser: bookedByUser?.toEntity(),
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      guests: guests,
      pricePerPlate: pricePerPlate,
      totalPrice: totalPrice,
      status: status,
      paymentStatus: paymentStatus,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      note: note,
      extras: extras,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory BookingApiModel.fromEntity(BookingEntity entity) {
    return BookingApiModel(
      bookingId: entity.bookingId,
      venueRef: entity.venueId,
      packageRef: entity.packageId,
      bookedByRef: entity.bookedBy,
      eventDate: entity.eventDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      guests: entity.guests,
      pricePerPlate: entity.pricePerPlate,
      totalPrice: entity.totalPrice,
      status: entity.status,
      paymentStatus: entity.paymentStatus,
      contactName: entity.contactName,
      contactPhone: entity.contactPhone,
      contactEmail: entity.contactEmail,
      note: entity.note,
      extras: entity.extras,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<BookingEntity> toEntityList(List<BookingApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
