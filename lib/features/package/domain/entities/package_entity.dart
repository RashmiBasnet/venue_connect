import 'package:equatable/equatable.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

class PackageCapacityEntity extends Equatable {
  final int minGuests;
  final int? maxGuests;

  const PackageCapacityEntity({required this.minGuests, this.maxGuests});

  @override
  List<Object?> get props => [minGuests, maxGuests];
}

class PackageAddOnEntity extends Equatable {
  final String title;
  final double price;

  const PackageAddOnEntity({required this.title, required this.price});

  @override
  List<Object?> get props => [title, price];
}

class PackageEntity extends Equatable {
  final String? packageId;
  final String venueId;
  final VenueEntity? venue;
  final String name;
  final String? description;
  final List<String> images;
  final double pricePerPlate;
  final PackageCapacityEntity? capacity;
  final List<String> inclusions;
  final List<PackageAddOnEntity> addOns;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PackageEntity({
    this.packageId,
    required this.venueId,
    this.venue,
    required this.name,
    this.description,
    required this.images,
    required this.pricePerPlate,
    this.capacity,
    required this.inclusions,
    this.addOns = const <PackageAddOnEntity>[],
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    packageId,
    venueId,
    venue,
    name,
    description,
    images,
    pricePerPlate,
    capacity,
    inclusions,
    addOns,
    isActive,
    createdAt,
    updatedAt,
  ];
}
