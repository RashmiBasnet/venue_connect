import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/services/hive/hive_service.dart';
import 'package:venue_connect/features/package/data/datasources/package_datasource.dart';
import 'package:venue_connect/features/package/data/models/package_hive_model.dart';

final packageLocalDatasourceProvider = Provider<PackageLocalDatasource>((ref) {
  return PackageLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class PackageLocalDatasource implements IPackageLocalDatasource {
  final HiveService _hiveService;

  PackageLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> cachePackages(List<PackageHiveModel> packages, {int? amount}) {
    return _hiveService.savePackages(packages, amount: amount);
  }

  @override
  Future<List<PackageHiveModel>> getAllPackages({int? amount}) {
    return _hiveService.getAllPackages(amount: amount);
  }

  @override
  Future<PackageHiveModel?> getPackageById(String packageId) async {
    return _hiveService.getPackageById(packageId);
  }

  @override
  Future<List<PackageHiveModel>> getPackagesByVenueId(String venueId) {
    return _hiveService.getPackagesByVenueId(venueId);
  }
}
