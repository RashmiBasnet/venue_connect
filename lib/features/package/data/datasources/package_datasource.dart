import 'package:venue_connect/features/package/data/models/package_api_model.dart';
import 'package:venue_connect/features/package/data/models/package_hive_model.dart';

abstract interface class IPackageLocalDatasource {
  Future<void> cachePackages(List<PackageHiveModel> packages, {int? amount});

  Future<List<PackageHiveModel>> getAllPackages({int? amount});

  Future<PackageHiveModel?> getPackageById(String packageId);

  Future<List<PackageHiveModel>> getPackagesByVenueId(String venueId);
}

abstract interface class IPackageRemoteDatasource {
  Future<List<PackageApiModel>> getAllPackages({
    int? page,
    int? size,
    String? search,
  });

  Future<PackageApiModel?> getPackageById(String packageId);

  Future<List<PackageApiModel>> getPackagesByVenueId(String venueId);
}
