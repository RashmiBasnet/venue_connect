import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/booking/presentation/pages/create_booking_screen.dart';
import 'package:venue_connect/features/booking/presentation/state/booking_state.dart';
import 'package:venue_connect/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/usecases/get_packages_by_venue_id_usecase.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

class MockGetPackagesByVenueIdUsecase extends Mock
    implements GetPackagesByVenueIdUsecase {}

class FakeBookingViewmodel extends BookingViewmodel {
  @override
  BookingState build() => const BookingState();
}

void main() {
  late MockGetPackagesByVenueIdUsecase mockGetPackagesByVenueIdUsecase;

  const tVenue = VenueEntity(
    venueId: 'v1',
    name: 'Crystal Banquet',
    address: VenueAddressEntity(city: 'Kathmandu', country: 'Nepal'),
    images: ['venue.jpg'],
    pricePerPlate: 1200,
    capacity: VenueCapacityEntity(minGuests: 100, maxGuests: 300),
    amenities: ['WIFI'],
    isActive: true,
  );

  const tPackage = PackageEntity(
    packageId: 'p1',
    venueId: 'v1',
    name: 'Wedding Package',
    images: ['pkg.jpg'],
    pricePerPlate: 1500,
    capacity: PackageCapacityEntity(minGuests: 80, maxGuests: 250),
    inclusions: ['Stage', 'Sound'],
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(
      const GetPackagesByVenueIdUsecaseParams(venueId: 'fallback'),
    );
  });

  setUp(() {
    mockGetPackagesByVenueIdUsecase = MockGetPackagesByVenueIdUsecase();
  });

  Future<void> pumpCreateBooking(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getPackagesByVenueIdUsecaseProvider.overrideWithValue(
            mockGetPackagesByVenueIdUsecase,
          ),
          bookingViewmodelProvider.overrideWith(FakeBookingViewmodel.new),
        ],
        child: const MaterialApp(home: CreateBookingScreen(venue: tVenue)),
      ),
    );
  }

  group('CreateBookingScreen', () {
    testWidgets('shows package loading indicator while fetching packages', (
      tester,
    ) async {
      final completer = Completer<Either<Failure, List<PackageEntity>>>();
      when(
        () => mockGetPackagesByVenueIdUsecase(any()),
      ).thenAnswer((_) => completer.future);

      await pumpCreateBooking(tester);

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      completer.complete(const Right([tPackage]));
      await tester.pumpAndSettle();
    });

    testWidgets('shows package dropdown data when package load succeeds', (
      tester,
    ) async {
      when(
        () => mockGetPackagesByVenueIdUsecase(any()),
      ).thenAnswer((_) async => const Right([tPackage]));

      await pumpCreateBooking(tester);
      await tester.pumpAndSettle();

      expect(find.text('Book Venue'), findsOneWidget);
      expect(find.textContaining('Book Crystal Banquet'), findsOneWidget);
      expect(find.text('Package (optional)'), findsOneWidget);
      expect(find.text('No package (use venue price)'), findsOneWidget);
      expect(find.text('Confirm Booking'), findsOneWidget);
    });

    testWidgets('shows package error text when package load fails', (
      tester,
    ) async {
      const failure = ApiFailure(message: 'Failed to fetch packages');
      when(
        () => mockGetPackagesByVenueIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await pumpCreateBooking(tester);
      await tester.pumpAndSettle();

      expect(find.text('Failed to fetch packages'), findsOneWidget);
    });

    testWidgets('shows form error when contact name is empty', (tester) async {
      when(
        () => mockGetPackagesByVenueIdUsecase(any()),
      ).thenAnswer((_) async => const Right([tPackage]));

      await pumpCreateBooking(tester);
      await tester.pumpAndSettle();

      final confirmButton = find.widgetWithText(
        ElevatedButton,
        'Confirm Booking',
      );
      await tester.scrollUntilVisible(
        confirmButton,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.text('Contact name is required'), findsOneWidget);
    });

    testWidgets('shows form error for invalid contact email', (tester) async {
      when(
        () => mockGetPackagesByVenueIdUsecase(any()),
      ).thenAnswer((_) async => const Right([tPackage]));

      await pumpCreateBooking(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(2), '9800000000');
      await tester.enterText(find.byType(TextFormField).at(3), 'invalid-email');

      final confirmButton = find.widgetWithText(
        ElevatedButton,
        'Confirm Booking',
      );
      await tester.scrollUntilVisible(
        confirmButton,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('shows warning when event date is missing on submit', (
      tester,
    ) async {
      when(
        () => mockGetPackagesByVenueIdUsecase(any()),
      ).thenAnswer((_) async => const Right([tPackage]));

      await pumpCreateBooking(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(2), '9800000000');

      final confirmButton = find.widgetWithText(
        ElevatedButton,
        'Confirm Booking',
      );
      await tester.scrollUntilVisible(
        confirmButton,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.text('Please select event date'), findsOneWidget);
    });
  });
}
