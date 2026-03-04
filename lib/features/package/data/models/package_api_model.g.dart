// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageCapacityApiModel _$PackageCapacityApiModelFromJson(
        Map<String, dynamic> json) =>
    PackageCapacityApiModel(
      minGuests: (json['minGuests'] as num).toInt(),
      maxGuests: (json['maxGuests'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PackageCapacityApiModelToJson(
        PackageCapacityApiModel instance) =>
    <String, dynamic>{
      'minGuests': instance.minGuests,
      'maxGuests': instance.maxGuests,
    };

PackageAddOnApiModel _$PackageAddOnApiModelFromJson(
        Map<String, dynamic> json) =>
    PackageAddOnApiModel(
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$PackageAddOnApiModelToJson(
        PackageAddOnApiModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'price': instance.price,
    };

PackageApiModel _$PackageApiModelFromJson(Map<String, dynamic> json) =>
    PackageApiModel(
      packageId: json['_id'] as String?,
      venueId: _venueIdFromRaw(json['venueId']),
      venue: _venueFromRaw(json['venue']),
      name: json['name'] as String,
      description: json['description'] as String?,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      pricePerPlate: (json['pricePerPlate'] as num).toDouble(),
      capacity: json['capacity'] == null
          ? null
          : PackageCapacityApiModel.fromJson(
              json['capacity'] as Map<String, dynamic>),
      inclusions: (json['inclusions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      addOns: (json['addOns'] as List<dynamic>?)
              ?.map((e) =>
                  PackageAddOnApiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PackageAddOnApiModel>[],
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PackageApiModelToJson(PackageApiModel instance) =>
    <String, dynamic>{
      '_id': instance.packageId,
      'venueId': instance.venueId,
      'venue': _venueToJson(instance.venue),
      'name': instance.name,
      'description': instance.description,
      'images': instance.images,
      'pricePerPlate': instance.pricePerPlate,
      'capacity': instance.capacity?.toJson(),
      'inclusions': instance.inclusions,
      'addOns': instance.addOns.map((e) => e.toJson()).toList(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
