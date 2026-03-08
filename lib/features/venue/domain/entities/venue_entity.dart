import 'package:equatable/equatable.dart';

class VenueAddressEntity extends Equatable {
  final String? area;
  final String city;
  final String country;
  final String? zipCode;

  const VenueAddressEntity({
    this.area,
    required this.city,
    required this.country,
    this.zipCode,
  });

  @override
  List<Object?> get props => [area, city, country, zipCode];
}

class VenueCapacityEntity extends Equatable {
  final int minGuests;
  final int maxGuests;

  const VenueCapacityEntity({required this.minGuests, required this.maxGuests});

  @override
  List<Object?> get props => [minGuests, maxGuests];
}

class VenueEntity extends Equatable {
  final String? venueId;
  final String name;
  final String? description;
  final VenueAddressEntity address;
  final List<String> images;
  final double pricePerPlate;
  final VenueCapacityEntity capacity;
  final List<String> amenities;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VenueEntity({
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

  @override
  List<Object?> get props => [
    venueId,
    name,
    description,
    address,
    images,
    pricePerPlate,
    capacity,
    amenities,
    isActive,
    createdAt,
    updatedAt,
  ];
}
