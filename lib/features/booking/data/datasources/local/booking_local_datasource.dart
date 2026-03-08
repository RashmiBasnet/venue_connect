import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/services/hive/hive_service.dart';
import 'package:venue_connect/features/booking/data/datasources/booking_datasource.dart';
import 'package:venue_connect/features/booking/data/models/booking_hive_model.dart';

final bookingLocalDatasourceProvider = Provider<BookingLocalDatasource>((ref) {
  return BookingLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class BookingLocalDatasource implements IBookingLocalDatasource {
  final HiveService _hiveService;

  BookingLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> cacheMyBookings(List<BookingHiveModel> bookings, {int? amount}) {
    return _hiveService.saveMyBookings(bookings, amount: amount);
  }

  @override
  Future<void> cacheMyBooking(BookingHiveModel booking) {
    return _hiveService.saveMyBooking(booking);
  }

  @override
  Future<List<BookingHiveModel>> getMyBookings({int? amount}) {
    return _hiveService.getMyBookings(amount: amount);
  }

  @override
  Future<BookingHiveModel?> getMyBookingById(String bookingId) async {
    return _hiveService.getMyBookingById(bookingId);
  }
}
