import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/booking/data/repositories/booking_repository.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';
import 'package:venue_connect/features/booking/domain/repositories/booking_repository.dart';

final createBookingUsecaseProvider = Provider<CreateBookingUsecase>((ref) {
  return CreateBookingUsecase(
    bookingRepository: ref.read(bookingRepositoryProvider),
  );
});

class CreateBookingUsecase
    implements UsecaseWithParams<BookingEntity, CreateBookingEntity> {
  final IBookingRepository _bookingRepository;

  CreateBookingUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(CreateBookingEntity params) {
    return _bookingRepository.createBooking(params);
  }
}
