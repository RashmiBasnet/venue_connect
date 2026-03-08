import 'package:venue_connect/features/venue/data/models/venue_api_model.dart';
import 'package:venue_connect/features/venue/data/models/venue_hive_model.dart';

abstract interface class IVenueLocalDatasource {
  Future<void> cacheVenues(List<VenueHiveModel> venues, {int? amount});

  Future<List<VenueHiveModel>> getAllVenues({int? amount});

  Future<VenueHiveModel?> getVenueById(String venueId);
}

abstract interface class IVenueRemoteDatasource {
  Future<List<VenueApiModel>> getAllVenues();

  Future<VenueApiModel?> getVenueById(String venueId);
}
