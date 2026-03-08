import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/repositories/booking_repository.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_booking_by_id_usecase.dart';

class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late GetMyBookingByIdUsecase usecase;
  late IBookingRepository mockBookingRepository;

  const tBookingId = 'b1';
  final tBooking = BookingEntity(
    bookingId: tBookingId,
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
    usecase = GetMyBookingByIdUsecase(bookingRepository: mockBookingRepository);
  });

  group('GetMyBookingById Usecase', () {
    test('Should return booking when fetch by id is successful', () async {
      // Arrange
      when(
        () => mockBookingRepository.getMyBookingById(tBookingId),
      ).thenAnswer((_) async => Right(tBooking));

      // Act
      final result = await usecase(
        const GetMyBookingByIdUsecaseParams(bookingId: tBookingId),
      );

      // Assert
      expect(result, Right(tBooking));
      verify(
        () => mockBookingRepository.getMyBookingById(tBookingId),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });

    test('Should return failure when fetch by id fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Booking not found');
      when(
        () => mockBookingRepository.getMyBookingById(tBookingId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const GetMyBookingByIdUsecaseParams(bookingId: tBookingId),
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockBookingRepository.getMyBookingById(tBookingId),
      ).called(1);
      verifyNoMoreInteractions(mockBookingRepository);
    });
  });

  group('GetMyBookingById Usecase Params', () {
    test('Should have correct props', () {
      const params = GetMyBookingByIdUsecaseParams(bookingId: tBookingId);
      expect(params.props, [tBookingId]);
    });
  });
}
