import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';
import 'package:venue_connect/features/booking/domain/repositories/booking_repository.dart';
import 'package:venue_connect/features/booking/domain/usecases/create_booking_usecase.dart';

class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late CreateBookingUsecase usecase;
  late IBookingRepository mockBookingRepository;

  const tRequest = CreateBookingEntity(
    venueId: 'v1',
    packageId: 'p1',
    eventDate: '2026-03-20',
    startTime: '10:00',
    endTime: '15:00',
    guests: 100,
    contactName: 'Test User',
    contactPhone: '9800000000',
    contactEmail: 'test@email.com',
    note: 'Birthday event',
  );

  final tBooking = BookingEntity(
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
  );

  setUp(() {
    mockBookingRepository = MockBookingRepository();
    usecase = CreateBookingUsecase(bookingRepository: mockBookingRepository);
  });

  group('CreateBooking Usecase', () {
    test('Should return BookingEntity when create is successful', () async {
      // Arrange
      when(
        () => mockBookingRepository.createBooking(tRequest),
      ).thenAnswer((_) async => Right(tBooking));

      // Act
      final result = await usecase(tRequest);

      // Assert
      expect(result, Right(tBooking));
      verify(() => mockBookingRepository.createBooking(tRequest)).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    test('Should return failure when create fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Booking failed');
      when(
        () => mockBookingRepository.createBooking(tRequest),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tRequest);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockBookingRepository.createBooking(tRequest)).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });
  });
}
