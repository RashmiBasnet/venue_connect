import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';
import 'package:venue_connect/features/package/domain/usecases/get_package_by_id_usecase.dart';

class MockPackageRepository extends Mock implements IPackageRepository {}

void main() {
  late GetPackageByIdUsecase usecase;
  late IPackageRepository mockPackageRepository;

  const tPackageId = 'p1';
  const tPackage = PackageEntity(
    packageId: tPackageId,
    venueId: 'v1',
    name: 'Wedding Package',
    images: ['pkg.jpg'],
    pricePerPlate: 1200,
    inclusions: ['Stage', 'Sound'],
    isActive: true,
  );

  setUp(() {
    mockPackageRepository = MockPackageRepository();
    usecase = GetPackageByIdUsecase(packageRepository: mockPackageRepository);
  });

  group('GetPackageById Usecase', () {
    test('Should return package when fetch by id is successful', () async {
      // Arrange
      when(
        () => mockPackageRepository.getPackageById(tPackageId),
      ).thenAnswer((_) async => const Right(tPackage));

      // Act
      final result = await usecase(
        const GetPackageByIdUsecaseParams(packageId: tPackageId),
      );

      // Assert
      expect(result, const Right(tPackage));
      verify(() => mockPackageRepository.getPackageById(tPackageId)).called(1);
      verifyNoMoreInteractions(mockPackageRepository);
    });

    test('Should return failure when fetch by id fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Package not found');
      when(
        () => mockPackageRepository.getPackageById(tPackageId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const GetPackageByIdUsecaseParams(packageId: tPackageId),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockPackageRepository.getPackageById(tPackageId)).called(1);
      verifyNoMoreInteractions(mockPackageRepository);
    });
  });

  group('GetPackageById Usecase Params', () {
    test('Should have correct props', () {
      const params = GetPackageByIdUsecaseParams(packageId: tPackageId);
      expect(params.props, [tPackageId]);
    });

    test('Two params with same values should be equal', () {
      const params1 = GetPackageByIdUsecaseParams(packageId: tPackageId);
      const params2 = GetPackageByIdUsecaseParams(packageId: tPackageId);
      expect(params1, params2);
    });
  });
}
