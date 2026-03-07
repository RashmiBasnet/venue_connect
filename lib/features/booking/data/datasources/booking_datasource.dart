import 'package:venue_connect/features/booking/data/models/booking_api_model.dart';
import 'package:venue_connect/features/booking/data/models/create_booking_api_model.dart';

abstract interface class IBookingRemoteDatasource {
  Future<BookingApiModel> createBooking(CreateBookingApiModel model);

  Future<List<BookingApiModel>> getMyBookings();

  Future<BookingApiModel?> getMyBookingById(String bookingId);
}
