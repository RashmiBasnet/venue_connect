import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_all_venues_usecase.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_venue_by_id_usecase.dart';
import 'package:venue_connect/features/venue/presentation/state/venue_state.dart';
import 'package:venue_connect/features/venue/presentation/view_model/venue_viewmodel.dart';

class MockGetAllVenuesUsecase extends Mock implements GetAllVenuesUsecase {}

class MockGetVenueByIdUsecase extends Mock implements GetVenueByIdUsecase {}

void main() {
  late MockGetAllVenuesUsecase mockGetAllVenuesUsecase;
  late MockGetVenueByIdUsecase mockGetVenueByIdUsecase;

  const tVenue = VenueEntity(
    venueId: 'v1',
    name: 'Test Venue',
    address: VenueAddressEntity(city: 'Kathmandu', country: 'Nepal'),
    images: ['img.jpg'],
    pricePerPlate: 1000,
    capacity: VenueCapacityEntity(minGuests: 50, maxGuests: 200),
    amenities: ['WIFI'],
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(const GetVenueByIdUsecaseParams(venueId: 'fallback'));
  });

  setUp(() {
    mockGetAllVenuesUsecase = MockGetAllVenuesUsecase();
    mockGetVenueByIdUsecase = MockGetVenueByIdUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getAllVenuesUsecaseProvider.overrideWithValue(mockGetAllVenuesUsecase),
        getVenueByIdUsecaseProvider.overrideWithValue(mockGetVenueByIdUsecase),
      ],
    );
  }

  group('VenueViewmodel', () {
    test('Initial state should be VenueStatus.initial', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(venueViewmodelProvider);
      expect(state.status, VenueStatus.initial);
      expect(state.venues, isEmpty);
      expect(state.selectedVenue, isNull);
    });

    test(
      'getAllVenues should set loaded state with venues on success',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        when(
          () => mockGetAllVenuesUsecase(),
        ).thenAnswer((_) async => const Right([tVenue]));

        await container.read(venueViewmodelProvider.notifier).getAllVenues();

        final state = container.read(venueViewmodelProvider);
        expect(state.status, VenueStatus.loaded);
        expect(state.venues, [tVenue]);
        expect(state.errorMessage, isNull);
      },
    );

    test('getAllVenues should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Failed to fetch venues');
      when(
        () => mockGetAllVenuesUsecase(),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(venueViewmodelProvider.notifier).getAllVenues();

      final state = container.read(venueViewmodelProvider);
      expect(state.status, VenueStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test('getVenueById should set selectedVenue on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockGetVenueByIdUsecase(any()),
      ).thenAnswer((_) async => const Right(tVenue));

      await container.read(venueViewmodelProvider.notifier).getVenueById('v1');

      final state = container.read(venueViewmodelProvider);
      expect(state.status, VenueStatus.loaded);
      expect(state.selectedVenue, tVenue);
      expect(state.errorMessage, isNull);
    });

    test('getVenueById should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Venue not found');
      when(
        () => mockGetVenueByIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(venueViewmodelProvider.notifier).getVenueById('v1');

      final state = container.read(venueViewmodelProvider);
      expect(state.status, VenueStatus.error);
      expect(state.errorMessage, failure.message);
    });
  });
}
