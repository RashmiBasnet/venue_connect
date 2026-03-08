import 'package:dartz/dartz.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';

abstract interface class IPackageRepository {
  Future<Either<Failure, List<PackageEntity>>> getAllPackages({
    int? page,
    int? size,
    String? search,
  });

  Future<Either<Failure, PackageEntity>> getPackageById(String packageId);

  Future<Either<Failure, List<PackageEntity>>> getPackagesByVenueId(
    String venueId,
  );
}
