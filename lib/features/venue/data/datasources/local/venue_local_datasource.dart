import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/services/hive/hive_service.dart';
import 'package:venue_connect/features/venue/data/datasources/venue_datasource.dart';
import 'package:venue_connect/features/venue/data/models/venue_hive_model.dart';

final venueLocalDatasourceProvider = Provider<VenueLocalDatasource>((ref) {
  return VenueLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class VenueLocalDatasource implements IVenueLocalDatasource {
  final HiveService _hiveService;

  VenueLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> cacheVenues(List<VenueHiveModel> venues, {int? amount}) async {
    await _hiveService.saveVenues(venues, amount: amount);
  }

  @override
  Future<List<VenueHiveModel>> getAllVenues({int? amount}) async {
    return _hiveService.getAllVenues(amount: amount);
  }

  @override
  Future<VenueHiveModel?> getVenueById(String venueId) async {
    return _hiveService.getVenueById(venueId);
  }
}
