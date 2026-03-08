import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_client.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/booking/data/datasources/booking_datasource.dart';
import 'package:venue_connect/features/booking/data/models/booking_api_model.dart';
import 'package:venue_connect/features/booking/data/models/create_booking_api_model.dart';

final bookingRemoteDatasourceProvider = Provider<BookingRemoteDatasource>((
  ref,
) {
  return BookingRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class BookingRemoteDatasource implements IBookingRemoteDatasource {
  final ApiClient _apiClient;

  BookingRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<BookingApiModel> createBooking(CreateBookingApiModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookings,
      data: model.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to create booking');
  }

  @override
  Future<List<BookingApiModel>> getMyBookings() async {
    final response = await _apiClient.get(ApiEndpoints.myBookings);

    if (response.data['success'] == true) {
      final data = (response.data['data'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>();

      return data.map(BookingApiModel.fromJson).toList();
    }

    return <BookingApiModel>[];
  }

  @override
  Future<BookingApiModel?> getMyBookingById(String bookingId) async {
    final response = await _apiClient.get(
      ApiEndpoints.myBookingById(bookingId),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return BookingApiModel.fromJson(data);
    }

    return null;
  }
}
