import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/usecases/get_package_by_id_usecase.dart';
import 'package:venue_connect/features/package/presentation/pages/package_detail_screen.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

class MockGetPackageByIdUsecase extends Mock implements GetPackageByIdUsecase {}

void main() {
  late MockGetPackageByIdUsecase mockGetPackageByIdUsecase;

  const tPackage = PackageEntity(
    packageId: 'p1',
    venueId: 'v1',
    venue: VenueEntity(
      venueId: 'v1',
      name: 'Crystal Banquet',
      address: VenueAddressEntity(city: 'Kathmandu', country: 'Nepal'),
      images: ['venue.jpg'],
      pricePerPlate: 1200,
      capacity: VenueCapacityEntity(minGuests: 100, maxGuests: 300),
      amenities: ['WIFI'],
      isActive: true,
    ),
    name: 'Wedding Package',
    description: 'Best package for weddings',
    images: ['pkg.jpg'],
    pricePerPlate: 1500,
    capacity: PackageCapacityEntity(minGuests: 50, maxGuests: 200),
    inclusions: ['Stage', 'Sound'],
    addOns: [PackageAddOnEntity(title: 'DJ', price: 5000)],
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(
      const GetPackageByIdUsecaseParams(packageId: 'fallback'),
    );
  });

  setUp(() {
    mockGetPackageByIdUsecase = MockGetPackageByIdUsecase();
  });

  Future<void> pumpPackageDetail(
    WidgetTester tester, {
    String packageId = 'p1',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getPackageByIdUsecaseProvider.overrideWithValue(
            mockGetPackageByIdUsecase,
          ),
        ],
        child: MaterialApp(home: PackageDetailScreen(packageId: packageId)),
      ),
    );
  }

  group('PackageDetailScreen', () {
    testWidgets('shows loading then package details on success', (
      tester,
    ) async {
      when(
        () => mockGetPackageByIdUsecase(any()),
      ).thenAnswer((_) async => const Right(tPackage));

      await pumpPackageDetail(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Package Details'), findsOneWidget);
      expect(find.text('Wedding Package'), findsOneWidget);
      expect(find.text('Offered By'), findsOneWidget);
      expect(find.text('Crystal Banquet'), findsOneWidget);
      expect(find.text('Inclusions'), findsOneWidget);
      expect(find.text('Stage'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Add-ons'), findsOneWidget);
      expect(find.text('DJ'), findsOneWidget);
    });

    testWidgets('shows error and retry button on failure', (tester) async {
      const failure = ApiFailure(message: 'Failed to load package');
      when(
        () => mockGetPackageByIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await pumpPackageDetail(tester);
      await tester.pumpAndSettle();

      expect(find.text('Failed to load package'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('retry loads package after initial failure', (tester) async {
      var callCount = 0;
      when(() => mockGetPackageByIdUsecase(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return const Left(ApiFailure(message: 'Temporary error'));
        }
        return const Right(tPackage);
      });

      await pumpPackageDetail(tester);
      await tester.pumpAndSettle();

      expect(find.text('Temporary error'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Wedding Package'), findsOneWidget);
      verify(() => mockGetPackageByIdUsecase(any())).called(2);
    });
  });
}
