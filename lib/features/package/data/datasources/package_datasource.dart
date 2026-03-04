import 'package:venue_connect/features/package/data/models/package_api_model.dart';

abstract interface class IPackageRemoteDatasource {
  Future<List<PackageApiModel>> getAllPackages({
    int? page,
    int? size,
    String? search,
  });

  Future<PackageApiModel?> getPackageById(String packageId);

  Future<List<PackageApiModel>> getPackagesByVenueId(String venueId);
}
