import 'package:json_annotation/json_annotation.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

part 'venue_api_model.g.dart';

@JsonSerializable()
class VenueAddressApiModel {
  final String? area;
  final String city;
  final String country;
  final String? zipCode;

  VenueAddressApiModel({
    this.area,
    required this.city,
    required this.country,
    this.zipCode,
  });

  factory VenueAddressApiModel.fromJson(Map<String, dynamic> json) =>
      _$VenueAddressApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$VenueAddressApiModelToJson(this);

  VenueAddressEntity toEntity() {
    return VenueAddressEntity(
      area: area,
      city: city,
      country: country,
      zipCode: zipCode,
    );
  }

  factory VenueAddressApiModel.fromEntity(VenueAddressEntity entity) {
    return VenueAddressApiModel(
      area: entity.area,
      city: entity.city,
      country: entity.country,
      zipCode: entity.zipCode,
    );
  }
}

@JsonSerializable()
class VenueCapacityApiModel {
  final int minGuests;
  final int maxGuests;

  VenueCapacityApiModel({required this.minGuests, required this.maxGuests});

  factory VenueCapacityApiModel.fromJson(Map<String, dynamic> json) =>
      _$VenueCapacityApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$VenueCapacityApiModelToJson(this);

  VenueCapacityEntity toEntity() {
    return VenueCapacityEntity(minGuests: minGuests, maxGuests: maxGuests);
  }

  factory VenueCapacityApiModel.fromEntity(VenueCapacityEntity entity) {
    return VenueCapacityApiModel(
      minGuests: entity.minGuests,
      maxGuests: entity.maxGuests,
    );
  }
}

@JsonSerializable()
class VenueApiModel {
  @JsonKey(name: '_id')
  final String? venueId;
  final String name;
  final String? description;
  final VenueAddressApiModel address;
  final List<String> images;
  final double pricePerPlate;
  final VenueCapacityApiModel capacity;
  final List<String> amenities;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VenueApiModel({
    this.venueId,
    required this.name,
    this.description,
    required this.address,
    required this.images,
    required this.pricePerPlate,
    required this.capacity,
    required this.amenities,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory VenueApiModel.fromJson(Map<String, dynamic> json) =>
      _$VenueApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$VenueApiModelToJson(this);

  VenueEntity toEntity() {
    return VenueEntity(
      venueId: venueId,
      name: name,
      description: description,
      address: address.toEntity(),
      images: images,
      pricePerPlate: pricePerPlate,
      capacity: capacity.toEntity(),
      amenities: amenities,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory VenueApiModel.fromEntity(VenueEntity entity) {
    return VenueApiModel(
      venueId: entity.venueId,
      name: entity.name,
      description: entity.description,
      address: VenueAddressApiModel.fromEntity(entity.address),
      images: entity.images,
      pricePerPlate: entity.pricePerPlate,
      capacity: VenueCapacityApiModel.fromEntity(entity.capacity),
      amenities: entity.amenities,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<VenueEntity> toEntityList(List<VenueApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
