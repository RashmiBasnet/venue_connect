import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_client.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/venue/data/datasources/venue_datasource.dart';
import 'package:venue_connect/features/venue/data/models/venue_api_model.dart';

final venueRemoteDatasourceProvider = Provider<VenueRemoteDatasource>((ref) {
  return VenueRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class VenueRemoteDatasource implements IVenueRemoteDatasource {
  final ApiClient _apiClient;

  VenueRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<VenueApiModel>> getAllVenues() async {
    final response = await _apiClient.get(ApiEndpoints.venues);

    if (response.data['success'] == true) {
      final data = (response.data['data'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>();

      return data.map(VenueApiModel.fromJson).toList();
    }

    return <VenueApiModel>[];
  }

  @override
  Future<VenueApiModel?> getVenueById(String venueId) async {
    final response = await _apiClient.get(ApiEndpoints.venueById(venueId));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return VenueApiModel.fromJson(data);
    }

    return null;
  }
}
