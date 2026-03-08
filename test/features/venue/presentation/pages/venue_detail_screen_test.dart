import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_venue_by_id_usecase.dart';
import 'package:venue_connect/features/venue/presentation/pages/venue_detail_screen.dart';

class MockGetVenueByIdUsecase extends Mock implements GetVenueByIdUsecase {}

void main() {
  late MockGetVenueByIdUsecase mockGetVenueByIdUsecase;

  const tVenue = VenueEntity(
    venueId: 'v1',
    name: 'Crystal Banquet',
    description: 'Great venue for events',
    address: VenueAddressEntity(
      area: 'Lalitpur',
      city: 'Kathmandu',
      country: 'Nepal',
      zipCode: '44600',
    ),
    images: ['test.jpg'],
    pricePerPlate: 1300,
    capacity: VenueCapacityEntity(minGuests: 100, maxGuests: 200),
    amenities: ['WIFI', 'PARKING'],
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(const GetVenueByIdUsecaseParams(venueId: 'fallback'));
  });

  setUp(() {
    mockGetVenueByIdUsecase = MockGetVenueByIdUsecase();
  });

  Future<void> pumpVenueDetail(
    WidgetTester tester, {
    String venueId = 'v1',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getVenueByIdUsecaseProvider.overrideWithValue(
            mockGetVenueByIdUsecase,
          ),
        ],
        child: MaterialApp(home: VenueDetailScreen(venueId: venueId)),
      ),
    );
  }

  group('VenueDetailScreen', () {
    testWidgets('shows loading then venue details on success', (tester) async {
      when(
        () => mockGetVenueByIdUsecase(any()),
      ).thenAnswer((_) async => const Right(tVenue));

      await pumpVenueDetail(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Venue Details'), findsOneWidget);
      expect(find.text('Crystal Banquet'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(
        find.textContaining('Lalitpur, Kathmandu, Nepal, 44600'),
        findsOneWidget,
      );
      expect(find.text('Amenities'), findsOneWidget);
      expect(find.text('WIFI'), findsOneWidget);
      expect(find.text('PARKING'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Book Now'), findsOneWidget);
    });

    testWidgets('shows error and retry button on failure', (tester) async {
      const failure = ApiFailure(message: 'Failed to load venue');
      when(
        () => mockGetVenueByIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await pumpVenueDetail(tester);
      await tester.pumpAndSettle();

      expect(find.text('Failed to load venue'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('retry loads venue after initial failure', (tester) async {
      var callCount = 0;
      when(() => mockGetVenueByIdUsecase(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return const Left(ApiFailure(message: 'Temporary error'));
        }
        return const Right(tVenue);
      });

      await pumpVenueDetail(tester);
      await tester.pumpAndSettle();

      expect(find.text('Temporary error'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Crystal Banquet'), findsOneWidget);
      verify(() => mockGetVenueByIdUsecase(any())).called(2);
    });
  });
}
