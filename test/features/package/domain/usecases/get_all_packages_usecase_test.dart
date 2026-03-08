import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';
import 'package:venue_connect/features/package/domain/usecases/get_all_packages_usecase.dart';

class MockPackageRepository extends Mock implements IPackageRepository {}

void main() {
  late GetAllPackagesUsecase usecase;
  late IPackageRepository mockPackageRepository;

  const tPackages = [
    PackageEntity(
      packageId: 'p1',
      venueId: 'v1',
      name: 'Wedding Package',
      images: ['pkg.jpg'],
      pricePerPlate: 1200,
      inclusions: ['Stage', 'Sound'],
      isActive: true,
    ),
  ];

  setUp(() {
    mockPackageRepository = MockPackageRepository();
    usecase = GetAllPackagesUsecase(packageRepository: mockPackageRepository);
  });

  group('GetAllPackages Usecase', () {
    test('Should return package list when fetch is successful', () async {
      // Arrange
      when(
        () => mockPackageRepository.getAllPackages(
          page: 1,
          size: 10,
          search: 'wedding',
        ),
      ).thenAnswer((_) async => const Right(tPackages));

      // Act
      final result = await usecase(
        const GetAllPackagesUsecaseParams(page: 1, size: 10, search: 'wedding'),
      );

      // Assert
      expect(result, const Right(tPackages));
      verify(
        () => mockPackageRepository.getAllPackages(
          page: 1,
          size: 10,
          search: 'wedding',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockPackageRepository);
    });

    test('Should return failure when fetch fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch packages');
      when(
        () => mockPackageRepository.getAllPackages(
          page: 1,
          size: 10,
          search: null,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const GetAllPackagesUsecaseParams(page: 1, size: 10),
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockPackageRepository.getAllPackages(
          page: 1,
          size: 10,
          search: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockPackageRepository);
    });
  });

  group('GetAllPackages Usecase Params', () {
    test('Should have correct props', () {
      const params = GetAllPackagesUsecaseParams(
        page: 1,
        size: 10,
        search: 'wedding',
      );
      expect(params.props, [1, 10, 'wedding']);
    });
  });
}
