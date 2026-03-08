import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/repositories/venue_repository.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_all_venues_usecase.dart';

class MockVenueRepository extends Mock implements IVenueRepository {}

void main() {
  late GetAllVenuesUsecase usecase;
  late IVenueRepository mockVenueRepository;

  const tVenues = [
    VenueEntity(
      venueId: 'v1',
      name: 'Test Venue',
      address: VenueAddressEntity(city: 'Kathmandu', country: 'Nepal'),
      images: ['img.jpg'],
      pricePerPlate: 1000,
      capacity: VenueCapacityEntity(minGuests: 50, maxGuests: 200),
      amenities: ['WIFI'],
      isActive: true,
    ),
  ];

  setUp(() {
    mockVenueRepository = MockVenueRepository();
    usecase = GetAllVenuesUsecase(venueRepository: mockVenueRepository);
  });

  group('GetAllVenues Usecase', () {
    test('Should return venue list when fetch is successful', () async {
      // Arrange
      when(
        () => mockVenueRepository.getAllVenues(),
      ).thenAnswer((_) async => const Right(tVenues));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tVenues));
      verify(() => mockVenueRepository.getAllVenues()).called(1);
      verifyNoMoreInteractions(mockVenueRepository);
    });

    test('Should return failure when fetch fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch venues');
      when(
        () => mockVenueRepository.getAllVenues(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockVenueRepository.getAllVenues()).called(1);
      verifyNoMoreInteractions(mockVenueRepository);
    });
  });
}
