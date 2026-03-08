import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/repositories/venue_repository.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_venue_by_id_usecase.dart';

class MockVenueRepository extends Mock implements IVenueRepository {}

void main() {
  late GetVenueByIdUsecase usecase;
  late IVenueRepository mockVenueRepository;

  const tVenueId = 'v1';
  const tVenue = VenueEntity(
    venueId: tVenueId,
    name: 'Test Venue',
    address: VenueAddressEntity(city: 'Kathmandu', country: 'Nepal'),
    images: ['img.jpg'],
    pricePerPlate: 1000,
    capacity: VenueCapacityEntity(minGuests: 50, maxGuests: 200),
    amenities: ['WIFI'],
    isActive: true,
  );

  setUp(() {
    mockVenueRepository = MockVenueRepository();
    usecase = GetVenueByIdUsecase(venueRepository: mockVenueRepository);
  });

  group('GetVenueById Usecase', () {
    test('Should return venue when fetch by id is successful', () async {
      // Arrange
      when(
        () => mockVenueRepository.getVenueById(tVenueId),
      ).thenAnswer((_) async => const Right(tVenue));

      // Act
      final result = await usecase(
        const GetVenueByIdUsecaseParams(venueId: tVenueId),
      );

      // Assert
      expect(result, const Right(tVenue));
      verify(() => mockVenueRepository.getVenueById(tVenueId)).called(1);
      verifyNoMoreInteractions(mockVenueRepository);
    });

    test('Should return failure when fetch by id fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Venue not found');
      when(
        () => mockVenueRepository.getVenueById(tVenueId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const GetVenueByIdUsecaseParams(venueId: tVenueId),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockVenueRepository.getVenueById(tVenueId)).called(1);
      verifyNoMoreInteractions(mockVenueRepository);
    });
  });

  group('GetVenueById Usecase Params', () {
    test('Should have correct props', () {
      const params = GetVenueByIdUsecaseParams(venueId: tVenueId);
      expect(params.props, [tVenueId]);
    });

    test('Two params with same values should be equal', () {
      const params1 = GetVenueByIdUsecaseParams(venueId: tVenueId);
      const params2 = GetVenueByIdUsecaseParams(venueId: tVenueId);
      expect(params1, params2);
    });
  });
}
