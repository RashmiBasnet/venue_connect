// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueAddressApiModel _$VenueAddressApiModelFromJson(
        Map<String, dynamic> json) =>
    VenueAddressApiModel(
      area: json['area'] as String?,
      city: json['city'] as String,
      country: json['country'] as String,
      zipCode: json['zipCode'] as String?,
    );

Map<String, dynamic> _$VenueAddressApiModelToJson(
        VenueAddressApiModel instance) =>
    <String, dynamic>{
      'area': instance.area,
      'city': instance.city,
      'country': instance.country,
      'zipCode': instance.zipCode,
    };

VenueCapacityApiModel _$VenueCapacityApiModelFromJson(
        Map<String, dynamic> json) =>
    VenueCapacityApiModel(
      minGuests: (json['minGuests'] as num).toInt(),
      maxGuests: (json['maxGuests'] as num).toInt(),
    );

Map<String, dynamic> _$VenueCapacityApiModelToJson(
        VenueCapacityApiModel instance) =>
    <String, dynamic>{
      'minGuests': instance.minGuests,
      'maxGuests': instance.maxGuests,
    };

VenueApiModel _$VenueApiModelFromJson(Map<String, dynamic> json) =>
    VenueApiModel(
      venueId: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: VenueAddressApiModel.fromJson(
          json['address'] as Map<String, dynamic>),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      pricePerPlate: (json['pricePerPlate'] as num).toDouble(),
      capacity: VenueCapacityApiModel.fromJson(
          json['capacity'] as Map<String, dynamic>),
      amenities:
          (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VenueApiModelToJson(VenueApiModel instance) =>
    <String, dynamic>{
      '_id': instance.venueId,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'images': instance.images,
      'pricePerPlate': instance.pricePerPlate,
      'capacity': instance.capacity,
      'amenities': instance.amenities,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
