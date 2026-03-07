import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/booking/data/repositories/booking_repository.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/repositories/booking_repository.dart';

final getMyBookingsUsecaseProvider = Provider<GetMyBookingsUsecase>((ref) {
  return GetMyBookingsUsecase(
    bookingRepository: ref.read(bookingRepositoryProvider),
  );
});

class GetMyBookingsUsecase
    implements UsecaseWithoutParams<List<BookingEntity>> {
  final IBookingRepository _bookingRepository;

  GetMyBookingsUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, List<BookingEntity>>> call() {
    return _bookingRepository.getMyBookings();
  }
}
