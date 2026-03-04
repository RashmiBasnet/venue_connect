import 'package:venue_connect/features/venue/data/models/venue_api_model.dart';

abstract interface class IVenueRemoteDatasource {
  Future<List<VenueApiModel>> getAllVenues();

  Future<VenueApiModel?> getVenueById(String venueId);
}
