import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_client.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/package/data/datasources/package_datasource.dart';
import 'package:venue_connect/features/package/data/models/package_api_model.dart';

final packageRemoteDatasourceProvider = Provider<PackageRemoteDatasource>((
  ref,
) {
  return PackageRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class PackageRemoteDatasource implements IPackageRemoteDatasource {
  final ApiClient _apiClient;

  PackageRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<PackageApiModel>> getAllPackages({
    int? page,
    int? size,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (size != null) 'size': size,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final response = await _apiClient.get(
      ApiEndpoints.packages,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    if (response.data['success'] == true) {
      final data = (response.data['data'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>();
      return data.map(PackageApiModel.fromJson).toList();
    }

    return <PackageApiModel>[];
  }

  @override
  Future<PackageApiModel?> getPackageById(String packageId) async {
    final response = await _apiClient.get(ApiEndpoints.packageById(packageId));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PackageApiModel.fromJson(data);
    }

    return null;
  }

  @override
  Future<List<PackageApiModel>> getPackagesByVenueId(String venueId) async {
    final response = await _apiClient.get(
      ApiEndpoints.packagesByVenueId(venueId),
    );

    if (response.data['success'] == true) {
      final data = (response.data['data'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>();
      return data.map(PackageApiModel.fromJson).toList();
    }

    return <PackageApiModel>[];
  }
}
