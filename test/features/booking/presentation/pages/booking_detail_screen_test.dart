import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_booking_by_id_usecase.dart';
import 'package:venue_connect/features/booking/presentation/pages/booking_detail_screen.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

class MockGetMyBookingByIdUsecase extends Mock
    implements GetMyBookingByIdUsecase {}

void main() {
  late MockGetMyBookingByIdUsecase mockGetMyBookingByIdUsecase;

  final tBooking = BookingEntity(
    bookingId: 'b1',
    venueId: 'v1',
    packageId: 'p1',
    bookedBy: 'u1',
    venue: const VenueEntity(
      venueId: 'v1',
      name: 'Crystal Banquet',
      address: VenueAddressEntity(
        area: 'Lalitpur',
        city: 'Kathmandu',
        country: 'Nepal',
        zipCode: '44600',
      ),
      images: ['venue.jpg'],
      pricePerPlate: 1200,
      capacity: VenueCapacityEntity(minGuests: 100, maxGuests: 300),
      amenities: ['WIFI'],
      isActive: true,
    ),
    package: const PackageEntity(
      packageId: 'p1',
      venueId: 'v1',
      name: 'Wedding Package',
      images: ['pkg.jpg'],
      pricePerPlate: 1500,
      inclusions: ['Stage', 'Sound'],
      isActive: true,
    ),
    eventDate: DateTime.parse('2026-03-20'),
    startTime: '10:00',
    endTime: '15:00',
    guests: 100,
    pricePerPlate: 1500,
    totalPrice: 150000,
    status: BookingStatus.pending,
    paymentStatus: PaymentStatus.unpaid,
    contactName: 'Test User',
    contactPhone: '9800000000',
    contactEmail: 'test@email.com',
    note: 'Birthday event',
  );

  setUpAll(() {
    registerFallbackValue(const GetMyBookingByIdUsecaseParams(bookingId: 'b1'));
  });

  setUp(() {
    mockGetMyBookingByIdUsecase = MockGetMyBookingByIdUsecase();
  });

  Future<void> pumpBookingDetail(
    WidgetTester tester, {
    String bookingId = 'b1',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getMyBookingByIdUsecaseProvider.overrideWithValue(
            mockGetMyBookingByIdUsecase,
          ),
        ],
        child: MaterialApp(home: BookingDetailScreen(bookingId: bookingId)),
      ),
    );
  }

  group('BookingDetailScreen', () {
    testWidgets('shows loading then booking details on success', (
      tester,
    ) async {
      when(
        () => mockGetMyBookingByIdUsecase(any()),
      ).thenAnswer((_) async => Right(tBooking));

      await pumpBookingDetail(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.textContaining('Booking ID: b1'), findsOneWidget);
      expect(find.text('Crystal Banquet'), findsOneWidget);
      expect(find.text('Wedding Package'), findsOneWidget);
      expect(find.text('Pay with Khalti'), findsOneWidget);

      final backButton = find.text('Back to Activity');
      await tester.scrollUntilVisible(
        backButton,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(backButton, findsOneWidget);
    });

    testWidgets('shows error and retry button on failure', (tester) async {
      const failure = ApiFailure(message: 'Failed to load booking');
      when(
        () => mockGetMyBookingByIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await pumpBookingDetail(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Exception: Failed to load booking'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('retry loads booking after initial failure', (tester) async {
      var callCount = 0;
      when(() => mockGetMyBookingByIdUsecase(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return const Left(ApiFailure(message: 'Temporary error'));
        }
        return Right(tBooking);
      });

      await pumpBookingDetail(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception: Temporary error'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Booking ID: b1'), findsOneWidget);
      verify(() => mockGetMyBookingByIdUsecase(any())).called(2);
    });
  });
}
