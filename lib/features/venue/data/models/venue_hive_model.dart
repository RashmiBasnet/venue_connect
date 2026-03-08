import 'package:hive/hive.dart';
import 'package:venue_connect/core/constants/hive_table_constant.dart';
import 'package:venue_connect/features/venue/data/models/venue_api_model.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

part 'venue_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.venueTypeId)
class VenueHiveModel extends HiveObject {
  @HiveField(0)
  final String? venueId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? area;

  @HiveField(4)
  final String city;

  @HiveField(5)
  final String country;

  @HiveField(6)
  final String? zipCode;

  @HiveField(7)
  final List<String> images;

  @HiveField(8)
  final double pricePerPlate;

  @HiveField(9)
  final int minGuests;

  @HiveField(10)
  final int maxGuests;

  @HiveField(11)
  final List<String> amenities;

  @HiveField(12)
  final bool isActive;

  @HiveField(13)
  final DateTime? createdAt;

  @HiveField(14)
  final DateTime? updatedAt;

  VenueHiveModel({
    this.venueId,
    required this.name,
    this.description,
    this.area,
    required this.city,
    required this.country,
    this.zipCode,
    required this.images,
    required this.pricePerPlate,
    required this.minGuests,
    required this.maxGuests,
    required this.amenities,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory VenueHiveModel.fromEntity(VenueEntity entity) {
    return VenueHiveModel(
      venueId: entity.venueId,
      name: entity.name,
      description: entity.description,
      area: entity.address.area,
      city: entity.address.city,
      country: entity.address.country,
      zipCode: entity.address.zipCode,
      images: entity.images,
      pricePerPlate: entity.pricePerPlate,
      minGuests: entity.capacity.minGuests,
      maxGuests: entity.capacity.maxGuests,
      amenities: entity.amenities,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  VenueEntity toEntity() {
    return VenueEntity(
      venueId: venueId,
      name: name,
      description: description,
      address: VenueAddressEntity(
        area: area,
        city: city,
        country: country,
        zipCode: zipCode,
      ),
      images: images,
      pricePerPlate: pricePerPlate,
      capacity: VenueCapacityEntity(minGuests: minGuests, maxGuests: maxGuests),
      amenities: amenities,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<VenueEntity> toEntityList(List<VenueHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  static List<VenueHiveModel> fromEntityList(List<VenueEntity> entities) {
    return entities.map(VenueHiveModel.fromEntity).toList();
  }

  factory VenueHiveModel.fromApiModel(VenueApiModel apiModel) {
    return VenueHiveModel(
      venueId: apiModel.venueId,
      name: apiModel.name,
      description: apiModel.description,
      area: apiModel.address.area,
      city: apiModel.address.city,
      country: apiModel.address.country,
      zipCode: apiModel.address.zipCode,
      images: apiModel.images,
      pricePerPlate: apiModel.pricePerPlate,
      minGuests: apiModel.capacity.minGuests,
      maxGuests: apiModel.capacity.maxGuests,
      amenities: apiModel.amenities,
      isActive: apiModel.isActive,
      createdAt: apiModel.createdAt,
      updatedAt: apiModel.updatedAt,
    );
  }
  static List<VenueHiveModel> fromApiModelList(List<VenueApiModel> apiModels) {
    return apiModels.map(VenueHiveModel.fromApiModel).toList();
  }
}
