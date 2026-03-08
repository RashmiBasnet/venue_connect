import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';
import 'package:venue_connect/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_booking_by_id_usecase.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:venue_connect/features/booking/presentation/state/booking_state.dart';
import 'package:venue_connect/features/booking/presentation/view_model/booking_viewmodel.dart';

class MockCreateBookingUsecase extends Mock implements CreateBookingUsecase {}

class MockGetMyBookingsUsecase extends Mock implements GetMyBookingsUsecase {}

class MockGetMyBookingByIdUsecase extends Mock
    implements GetMyBookingByIdUsecase {}

void main() {
  late MockCreateBookingUsecase mockCreateBookingUsecase;
  late MockGetMyBookingsUsecase mockGetMyBookingsUsecase;
  late MockGetMyBookingByIdUsecase mockGetMyBookingByIdUsecase;

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

  setUpAll(() {
    registerFallbackValue(tRequest);
    registerFallbackValue(const GetMyBookingByIdUsecaseParams(bookingId: 'b1'));
  });

  setUp(() {
    mockCreateBookingUsecase = MockCreateBookingUsecase();
    mockGetMyBookingsUsecase = MockGetMyBookingsUsecase();
    mockGetMyBookingByIdUsecase = MockGetMyBookingByIdUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        createBookingUsecaseProvider.overrideWithValue(
          mockCreateBookingUsecase,
        ),
        getMyBookingsUsecaseProvider.overrideWithValue(
          mockGetMyBookingsUsecase,
        ),
        getMyBookingByIdUsecaseProvider.overrideWithValue(
          mockGetMyBookingByIdUsecase,
        ),
      ],
    );
  }

  group('BookingViewmodel', () {
    test('Initial state should be BookingStateStatus.initial', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(bookingViewmodelProvider);
      expect(state.status, BookingStateStatus.initial);
      expect(state.bookings, isEmpty);
      expect(state.selectedBooking, isNull);
    });

    test('createBooking should set created state on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockCreateBookingUsecase(any()),
      ).thenAnswer((_) async => Right(tBooking));

      await container
          .read(bookingViewmodelProvider.notifier)
          .createBooking(tRequest);

      final state = container.read(bookingViewmodelProvider);
      expect(state.status, BookingStateStatus.created);
      expect(state.selectedBooking, tBooking);
      expect(state.bookings.first, tBooking);
      expect(state.errorMessage, isNull);
    });

    test('createBooking should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Booking failed');
      when(
        () => mockCreateBookingUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(bookingViewmodelProvider.notifier)
          .createBooking(tRequest);

      final state = container.read(bookingViewmodelProvider);
      expect(state.status, BookingStateStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test('getMyBookings should set loaded state on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockGetMyBookingsUsecase(),
      ).thenAnswer((_) async => Right([tBooking]));

      await container.read(bookingViewmodelProvider.notifier).getMyBookings();

      final state = container.read(bookingViewmodelProvider);
      expect(state.status, BookingStateStatus.loaded);
      expect(state.bookings, [tBooking]);
      expect(state.errorMessage, isNull);
    });

    test('getMyBookings should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Failed to fetch bookings');
      when(
        () => mockGetMyBookingsUsecase(),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(bookingViewmodelProvider.notifier).getMyBookings();

      final state = container.read(bookingViewmodelProvider);
      expect(state.status, BookingStateStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test('getMyBookingById should set selected booking on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockGetMyBookingByIdUsecase(any()),
      ).thenAnswer((_) async => Right(tBooking));

      await container
          .read(bookingViewmodelProvider.notifier)
          .getMyBookingById('b1');

      final state = container.read(bookingViewmodelProvider);
      expect(state.status, BookingStateStatus.loaded);
      expect(state.selectedBooking, tBooking);
      expect(state.errorMessage, isNull);
    });

    test('getMyBookingById should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Booking not found');
      when(
        () => mockGetMyBookingByIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(bookingViewmodelProvider.notifier)
          .getMyBookingById('b1');

      final state = container.read(bookingViewmodelProvider);
      expect(state.status, BookingStateStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test('clearSelectedBooking should clear selected booking', () {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockGetMyBookingByIdUsecase(any()),
      ).thenAnswer((_) async => Right(tBooking));

      final notifier = container.read(bookingViewmodelProvider.notifier);
      notifier.getMyBookingById('b1');
      notifier.clearSelectedBooking();

      final state = container.read(bookingViewmodelProvider);
      expect(state.selectedBooking, isNull);
    });
  });
}
