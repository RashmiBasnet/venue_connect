import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/booking/data/repositories/booking_repository.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/repositories/booking_repository.dart';

class GetMyBookingByIdUsecaseParams extends Equatable {
  final String bookingId;

  const GetMyBookingByIdUsecaseParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

final getMyBookingByIdUsecaseProvider = Provider<GetMyBookingByIdUsecase>((
  ref,
) {
  return GetMyBookingByIdUsecase(
    bookingRepository: ref.read(bookingRepositoryProvider),
  );
});

class GetMyBookingByIdUsecase
    implements UsecaseWithParams<BookingEntity, GetMyBookingByIdUsecaseParams> {
  final IBookingRepository _bookingRepository;

  GetMyBookingByIdUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    GetMyBookingByIdUsecaseParams params,
  ) {
    return _bookingRepository.getMyBookingById(params.bookingId);
  }
}
