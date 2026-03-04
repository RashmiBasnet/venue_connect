import 'package:dartz/dartz.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

abstract interface class IVenueRepository {
  Future<Either<Failure, List<VenueEntity>>> getAllVenues();
  Future<Either<Failure, VenueEntity>> getVenueById(String venueId);
}
