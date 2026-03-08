import 'package:hive/hive.dart';
import 'package:venue_connect/core/constants/hive_table_constant.dart';
import 'package:venue_connect/features/booking/data/models/booking_api_model.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

part 'booking_hive_model.g.dart';

BookingStatus _bookingStatusFromName(String? value) {
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

PaymentStatus _paymentStatusFromName(String? value) {
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

@HiveType(typeId: HiveTableConstant.bookingTypeId)
class BookingHiveModel extends HiveObject {
  @HiveField(0)
  final String? bookingId;

  @HiveField(1)
  final String venueId;

  @HiveField(2)
  final String? packageId;

  @HiveField(3)
  final String bookedBy;

  @HiveField(4)
  final DateTime eventDate;

  @HiveField(5)
  final String startTime;

  @HiveField(6)
  final String endTime;

  @HiveField(7)
  final int guests;

  @HiveField(8)
  final double pricePerPlate;

  @HiveField(9)
  final double totalPrice;

  @HiveField(10)
  final String status;

  @HiveField(11)
  final String paymentStatus;

  @HiveField(12)
  final String contactName;

  @HiveField(13)
  final String contactPhone;

  @HiveField(14)
  final String? contactEmail;

  @HiveField(15)
  final String? note;

  @HiveField(16)
  final List<String> extras;

  @HiveField(17)
  final String? venueName;

  @HiveField(18)
  final String? venueArea;

  @HiveField(19)
  final String? venueCity;

  @HiveField(20)
  final String? venueCountry;

  @HiveField(21)
  final String? venueImage;

  @HiveField(22)
  final String? packageName;

  @HiveField(23)
  final DateTime? createdAt;

  @HiveField(24)
  final DateTime? updatedAt;

  BookingHiveModel({
    this.bookingId,
    required this.venueId,
    this.packageId,
    required this.bookedBy,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.guests,
    required this.pricePerPlate,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.note,
    this.extras = const <String>[],
    this.venueName,
    this.venueArea,
    this.venueCity,
    this.venueCountry,
    this.venueImage,
    this.packageName,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingHiveModel.fromApiModel(BookingApiModel apiModel) {
    return BookingHiveModel(
      bookingId: apiModel.bookingId,
      venueId: apiModel.venueId,
      packageId: apiModel.packageId,
      bookedBy: apiModel.bookedBy,
      eventDate: apiModel.eventDate,
      startTime: apiModel.startTime,
      endTime: apiModel.endTime,
      guests: apiModel.guests,
      pricePerPlate: apiModel.pricePerPlate,
      totalPrice: apiModel.totalPrice,
      status: apiModel.status.name,
      paymentStatus: apiModel.paymentStatus.name,
      contactName: apiModel.contactName,
      contactPhone: apiModel.contactPhone,
      contactEmail: apiModel.contactEmail,
      note: apiModel.note,
      extras: apiModel.extras,
      venueName: apiModel.venue?.name,
      venueArea: apiModel.venue?.address.area,
      venueCity: apiModel.venue?.address.city,
      venueCountry: apiModel.venue?.address.country,
      venueImage: apiModel.venue?.images.isNotEmpty == true
          ? apiModel.venue!.images.first
          : null,
      packageName: apiModel.package?.name,
      createdAt: apiModel.createdAt,
      updatedAt: apiModel.updatedAt,
    );
  }

  factory BookingHiveModel.fromEntity(BookingEntity entity) {
    return BookingHiveModel(
      bookingId: entity.bookingId,
      venueId: entity.venueId,
      packageId: entity.packageId,
      bookedBy: entity.bookedBy,
      eventDate: entity.eventDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      guests: entity.guests,
      pricePerPlate: entity.pricePerPlate,
      totalPrice: entity.totalPrice,
      status: entity.status.name,
      paymentStatus: entity.paymentStatus.name,
      contactName: entity.contactName,
      contactPhone: entity.contactPhone,
      contactEmail: entity.contactEmail,
      note: entity.note,
      extras: entity.extras,
      venueName: entity.venue?.name,
      venueArea: entity.venue?.address.area,
      venueCity: entity.venue?.address.city,
      venueCountry: entity.venue?.address.country,
      venueImage: entity.venue?.images.isNotEmpty == true
          ? entity.venue!.images.first
          : null,
      packageName: entity.package?.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BookingEntity toEntity() {
    final resolvedCity = (venueCity ?? '').trim().isNotEmpty
        ? venueCity!
        : 'Kathmandu';
    final resolvedCountry = (venueCountry ?? '').trim().isNotEmpty
        ? venueCountry!
        : 'Nepal';

    final VenueEntity? venueEntity =
        (venueName ?? '').trim().isNotEmpty ||
            (venueImage ?? '').trim().isNotEmpty
        ? VenueEntity(
            venueId: venueId,
            name: (venueName ?? '').trim().isNotEmpty
                ? venueName!
                : 'Unknown venue',
            description: null,
            address: VenueAddressEntity(
              area: venueArea,
              city: resolvedCity,
              country: resolvedCountry,
            ),
            images: (venueImage ?? '').trim().isNotEmpty
                ? <String>[venueImage!]
                : const <String>[],
            pricePerPlate: pricePerPlate,
            capacity: VenueCapacityEntity(
              minGuests: 1,
              maxGuests: guests > 1 ? guests : 1,
            ),
            amenities: const <String>[],
            isActive: true,
            createdAt: null,
            updatedAt: null,
          )
        : null;

    final PackageEntity? packageEntity =
        (packageId ?? '').trim().isNotEmpty ||
            (packageName ?? '').trim().isNotEmpty
        ? PackageEntity(
            packageId: packageId,
            venueId: venueId,
            name: (packageName ?? '').trim().isNotEmpty
                ? packageName!
                : 'Unknown package',
            description: null,
            images: const <String>[],
            pricePerPlate: pricePerPlate,
            capacity: null,
            inclusions: const <String>[],
            addOns: const <PackageAddOnEntity>[],
            isActive: true,
            createdAt: null,
            updatedAt: null,
          )
        : null;

    return BookingEntity(
      bookingId: bookingId,
      venueId: venueId,
      packageId: packageId,
      bookedBy: bookedBy,
      venue: venueEntity,
      package: packageEntity,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      guests: guests,
      pricePerPlate: pricePerPlate,
      totalPrice: totalPrice,
      status: _bookingStatusFromName(status),
      paymentStatus: _paymentStatusFromName(paymentStatus),
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      note: note,
      extras: extras,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<BookingHiveModel> fromApiModelList(List<BookingApiModel> models) {
    return models.map(BookingHiveModel.fromApiModel).toList();
  }

  static List<BookingEntity> toEntityList(List<BookingHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
