import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/repositories/booking_repository.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_bookings_usecase.dart';

class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late GetMyBookingsUsecase usecase;
  late IBookingRepository mockBookingRepository;

  final tBookings = [
    BookingEntity(
      bookingId: 'b1',
      venueId: 'v1',
      packageId: 'p1',
      bookedBy: 'u1',
      eventDate: DateTime.parse('2026-03-20'),
      startTime: '10:00',
      endTime: '15:00',
      guests: 100,
      pricePerPlate: 1000,
      totalPrice: 100000,
      contactName: 'Test User',
      contactPhone: '9800000000',
      contactEmail: 'test@email.com',
      note: 'Birthday event',
    ),
  ];

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    usecase = GetMyBookingsUsecase(bookingRepository: mockBookingRepository);
  });

  group('GetMyBookings Usecase', () {
    test('Should return booking list when fetch is successful', () async {
      // Arrange
      when(
        () => mockBookingRepository.getMyBookings(),
      ).thenAnswer((_) async => Right(tBookings));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tBookings));
      verify(() => mockBookingRepository.getMyBookings()).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    test('Should return failure when fetch fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch bookings');
      when(
        () => mockBookingRepository.getMyBookings(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockBookingRepository.getMyBookings()).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });
  });
}
