import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';
import 'package:venue_connect/features/package/domain/usecases/get_packages_by_venue_id_usecase.dart';

class MockPackageRepository extends Mock implements IPackageRepository {}

void main() {
  late GetPackagesByVenueIdUsecase usecase;
  late IPackageRepository mockPackageRepository;

  const tVenueId = 'v1';
  const tPackages = [
    PackageEntity(
      packageId: 'p1',
      venueId: tVenueId,
      name: 'Wedding Package',
      images: ['pkg.jpg'],
      pricePerPlate: 1200,
      inclusions: ['Stage', 'Sound'],
      isActive: true,
    ),
  ];

  setUp(() {
    mockPackageRepository = MockPackageRepository();
    usecase = GetPackagesByVenueIdUsecase(
      packageRepository: mockPackageRepository,
    );
  });

  group('GetPackagesByVenueId Usecase', () {
    test(
      'Should return package list when fetch by venue id is successful',
      () async {
        // Arrange
        when(
          () => mockPackageRepository.getPackagesByVenueId(tVenueId),
        ).thenAnswer((_) async => const Right(tPackages));

        // Act
        final result = await usecase(
          const GetPackagesByVenueIdUsecaseParams(venueId: tVenueId),
        );

        // Assert
        expect(result, const Right(tPackages));
        verify(
          () => mockPackageRepository.getPackagesByVenueId(tVenueId),
        ).called(1);
        verifyNoMoreInteractions(mockPackageRepository);
      },
    );

    test('Should return failure when fetch by venue id fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch packages');
      when(
        () => mockPackageRepository.getPackagesByVenueId(tVenueId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const GetPackagesByVenueIdUsecaseParams(venueId: tVenueId),
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockPackageRepository.getPackagesByVenueId(tVenueId),
      ).called(1);
      verifyNoMoreInteractions(mockPackageRepository);
    });
  });

  group('GetPackagesByVenueId Usecase Params', () {
    test('Should have correct props', () {
      const params = GetPackagesByVenueIdUsecaseParams(venueId: tVenueId);
      expect(params.props, [tVenueId]);
    });
  });
}
