import 'package:dartz/dartz.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';

abstract interface class IBookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking(
    CreateBookingEntity request,
  );

  Future<Either<Failure, List<BookingEntity>>> getMyBookings();

  Future<Either<Failure, BookingEntity>> getMyBookingById(String bookingId);
}
