import 'package:json_annotation/json_annotation.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/venue/data/models/venue_api_model.dart';

part 'package_api_model.g.dart';

String _venueIdFromRaw(dynamic value) {
  if (value is String) {
    return value;
  }

  if (value is Map<String, dynamic>) {
    return (value['_id'] as String?) ?? '';
  }

  return '';
}

VenueApiModel? _venueFromRaw(dynamic value) {
  if (value is! Map<String, dynamic>) {
    return null;
  }

  final normalized = <String, dynamic>{...value};

  if (normalized['name'] == null) {
    normalized['name'] = 'Unknown venue';
  }
  if (normalized['address'] == null) {
    normalized['address'] = {'city': 'Kathmandu', 'country': 'Nepal'};
  }
  if (normalized['images'] == null) {
    normalized['images'] = <dynamic>[];
  }
  if (normalized['pricePerPlate'] == null) {
    normalized['pricePerPlate'] = 0;
  }
  if (normalized['capacity'] == null) {
    normalized['capacity'] = {'minGuests': 1, 'maxGuests': 1};
  }
  if (normalized['amenities'] == null) {
    normalized['amenities'] = <dynamic>[];
  }
  if (normalized['isActive'] == null) {
    normalized['isActive'] = true;
  }

  return VenueApiModel.fromJson(normalized);
}

Map<String, dynamic>? _venueToJson(VenueApiModel? venue) => venue?.toJson();

@JsonSerializable()
class PackageCapacityApiModel {
  final int minGuests;
  final int? maxGuests;

  PackageCapacityApiModel({required this.minGuests, this.maxGuests});

  factory PackageCapacityApiModel.fromJson(Map<String, dynamic> json) =>
      _$PackageCapacityApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageCapacityApiModelToJson(this);

  PackageCapacityEntity toEntity() {
    return PackageCapacityEntity(minGuests: minGuests, maxGuests: maxGuests);
  }

  factory PackageCapacityApiModel.fromEntity(PackageCapacityEntity entity) {
    return PackageCapacityApiModel(
      minGuests: entity.minGuests,
      maxGuests: entity.maxGuests,
    );
  }
}

@JsonSerializable()
class PackageAddOnApiModel {
  final String title;
  final double price;

  PackageAddOnApiModel({required this.title, required this.price});

  factory PackageAddOnApiModel.fromJson(Map<String, dynamic> json) =>
      _$PackageAddOnApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageAddOnApiModelToJson(this);

  PackageAddOnEntity toEntity() {
    return PackageAddOnEntity(title: title, price: price);
  }

  factory PackageAddOnApiModel.fromEntity(PackageAddOnEntity entity) {
    return PackageAddOnApiModel(title: entity.title, price: entity.price);
  }
}

@JsonSerializable(explicitToJson: true)
class PackageApiModel {
  @JsonKey(name: '_id')
  final String? packageId;

  @JsonKey(fromJson: _venueIdFromRaw)
  final String venueId;

  @JsonKey(fromJson: _venueFromRaw, toJson: _venueToJson)
  final VenueApiModel? venue;

  final String name;
  final String? description;
  final List<String> images;
  final double pricePerPlate;
  final PackageCapacityApiModel? capacity;
  final List<String> inclusions;
  final List<PackageAddOnApiModel> addOns;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PackageApiModel({
    this.packageId,
    required this.venueId,
    this.venue,
    required this.name,
    this.description,
    required this.images,
    required this.pricePerPlate,
    this.capacity,
    required this.inclusions,
    this.addOns = const <PackageAddOnApiModel>[],
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageApiModel.fromJson(Map<String, dynamic> json) =>
      _$PackageApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageApiModelToJson(this);

  PackageEntity toEntity() {
    return PackageEntity(
      packageId: packageId,
      venueId: venueId,
      venue: venue?.toEntity(),
      name: name,
      description: description,
      images: images,
      pricePerPlate: pricePerPlate,
      capacity: capacity?.toEntity(),
      inclusions: inclusions,
      addOns: addOns.map((model) => model.toEntity()).toList(),
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PackageApiModel.fromEntity(PackageEntity entity) {
    return PackageApiModel(
      packageId: entity.packageId,
      venueId: entity.venueId,
      venue: entity.venue != null
          ? VenueApiModel.fromEntity(entity.venue!)
          : null,
      name: entity.name,
      description: entity.description,
      images: entity.images,
      pricePerPlate: entity.pricePerPlate,
      capacity: entity.capacity != null
          ? PackageCapacityApiModel.fromEntity(entity.capacity!)
          : null,
      inclusions: entity.inclusions,
      addOns: entity.addOns
          .map((addOn) => PackageAddOnApiModel.fromEntity(addOn))
          .toList(),
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<PackageEntity> toEntityList(List<PackageApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
