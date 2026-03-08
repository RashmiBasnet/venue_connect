import 'package:hive/hive.dart';
import 'package:venue_connect/core/constants/hive_table_constant.dart';
import 'package:venue_connect/features/package/data/models/package_api_model.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';

part 'package_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.packageTypeId)
class PackageHiveModel extends HiveObject {
  @HiveField(0)
  final String? packageId;

  @HiveField(1)
  final String venueId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final List<String> images;

  @HiveField(5)
  final double pricePerPlate;

  @HiveField(6)
  final int? minGuests;

  @HiveField(7)
  final int? maxGuests;

  @HiveField(8)
  final List<String> inclusions;

  @HiveField(9)
  final List<Map<String, dynamic>> addOns;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final DateTime? createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  PackageHiveModel({
    this.packageId,
    required this.venueId,
    required this.name,
    this.description,
    required this.images,
    required this.pricePerPlate,
    this.minGuests,
    this.maxGuests,
    required this.inclusions,
    this.addOns = const <Map<String, dynamic>>[],
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageHiveModel.fromEntity(PackageEntity entity) {
    return PackageHiveModel(
      packageId: entity.packageId,
      venueId: entity.venueId,
      name: entity.name,
      description: entity.description,
      images: entity.images,
      pricePerPlate: entity.pricePerPlate,
      minGuests: entity.capacity?.minGuests,
      maxGuests: entity.capacity?.maxGuests,
      inclusions: entity.inclusions,
      addOns: entity.addOns
          .map((addOn) => <String, dynamic>{
            'title': addOn.title,
            'price': addOn.price,
          })
          .toList(),
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory PackageHiveModel.fromApiModel(PackageApiModel apiModel) {
    return PackageHiveModel(
      packageId: apiModel.packageId,
      venueId: apiModel.venueId,
      name: apiModel.name,
      description: apiModel.description,
      images: apiModel.images,
      pricePerPlate: apiModel.pricePerPlate,
      minGuests: apiModel.capacity?.minGuests,
      maxGuests: apiModel.capacity?.maxGuests,
      inclusions: apiModel.inclusions,
      addOns: apiModel.addOns
          .map((addOn) => <String, dynamic>{
            'title': addOn.title,
            'price': addOn.price,
          })
          .toList(),
      isActive: apiModel.isActive,
      createdAt: apiModel.createdAt,
      updatedAt: apiModel.updatedAt,
    );
  }

  PackageEntity toEntity() {
    final addOnEntities = addOns.map((addOn) {
      return PackageAddOnEntity(
        title: (addOn['title'] as String?) ?? '',
        price: ((addOn['price'] as num?) ?? 0).toDouble(),
      );
    }).toList();

    return PackageEntity(
      packageId: packageId,
      venueId: venueId,
      name: name,
      description: description,
      images: images,
      pricePerPlate: pricePerPlate,
      capacity: minGuests == null
          ? null
          : PackageCapacityEntity(minGuests: minGuests!, maxGuests: maxGuests),
      inclusions: inclusions,
      addOns: addOnEntities,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<PackageEntity> toEntityList(List<PackageHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  static List<PackageHiveModel> fromApiModelList(List<PackageApiModel> models) {
    return models.map(PackageHiveModel.fromApiModel).toList();
  }

  static List<PackageHiveModel> fromEntityList(List<PackageEntity> entities) {
    return entities.map(PackageHiveModel.fromEntity).toList();
  }
}
