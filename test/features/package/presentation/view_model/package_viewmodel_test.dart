import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/usecases/get_all_packages_usecase.dart';
import 'package:venue_connect/features/package/domain/usecases/get_package_by_id_usecase.dart';
import 'package:venue_connect/features/package/domain/usecases/get_packages_by_venue_id_usecase.dart';
import 'package:venue_connect/features/package/presentation/state/package_state.dart';
import 'package:venue_connect/features/package/presentation/view_model/package_viewmodel.dart';

class MockGetAllPackagesUsecase extends Mock implements GetAllPackagesUsecase {}

class MockGetPackageByIdUsecase extends Mock implements GetPackageByIdUsecase {}

class MockGetPackagesByVenueIdUsecase extends Mock
    implements GetPackagesByVenueIdUsecase {}

void main() {
  late MockGetAllPackagesUsecase mockGetAllPackagesUsecase;
  late MockGetPackageByIdUsecase mockGetPackageByIdUsecase;
  late MockGetPackagesByVenueIdUsecase mockGetPackagesByVenueIdUsecase;

  const tPackage = PackageEntity(
    packageId: 'p1',
    venueId: 'v1',
    name: 'Wedding Package',
    images: ['pkg.jpg'],
    pricePerPlate: 1200,
    inclusions: ['Stage', 'Sound'],
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(const GetAllPackagesUsecaseParams());
    registerFallbackValue(
      const GetPackageByIdUsecaseParams(packageId: 'fallback'),
    );
    registerFallbackValue(
      const GetPackagesByVenueIdUsecaseParams(venueId: 'fallback'),
    );
  });

  setUp(() {
    mockGetAllPackagesUsecase = MockGetAllPackagesUsecase();
    mockGetPackageByIdUsecase = MockGetPackageByIdUsecase();
    mockGetPackagesByVenueIdUsecase = MockGetPackagesByVenueIdUsecase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getAllPackagesUsecaseProvider.overrideWithValue(
          mockGetAllPackagesUsecase,
        ),
        getPackageByIdUsecaseProvider.overrideWithValue(
          mockGetPackageByIdUsecase,
        ),
        getPackagesByVenueIdUsecaseProvider.overrideWithValue(
          mockGetPackagesByVenueIdUsecase,
        ),
      ],
    );
  }

  group('PackageViewmodel', () {
    test('Initial state should be PackageStatus.initial', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(packageViewmodelProvider);
      expect(state.status, PackageStatus.initial);
      expect(state.packages, isEmpty);
      expect(state.selectedPackage, isNull);
    });

    test(
      'getAllPackages should set loaded state with packages on success',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        when(
          () => mockGetAllPackagesUsecase(any()),
        ).thenAnswer((_) async => const Right([tPackage]));

        await container
            .read(packageViewmodelProvider.notifier)
            .getAllPackages(page: 1, size: 10);

        final state = container.read(packageViewmodelProvider);
        expect(state.status, PackageStatus.loaded);
        expect(state.packages, [tPackage]);
        expect(state.errorMessage, isNull);
      },
    );

    test('getAllPackages should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Failed to fetch packages');
      when(
        () => mockGetAllPackagesUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(packageViewmodelProvider.notifier)
          .getAllPackages(page: 1, size: 10);

      final state = container.read(packageViewmodelProvider);
      expect(state.status, PackageStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test('getPackageById should set selectedPackage on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockGetPackageByIdUsecase(any()),
      ).thenAnswer((_) async => const Right(tPackage));

      await container
          .read(packageViewmodelProvider.notifier)
          .getPackageById('p1');

      final state = container.read(packageViewmodelProvider);
      expect(state.status, PackageStatus.loaded);
      expect(state.selectedPackage, tPackage);
      expect(state.errorMessage, isNull);
    });

    test('getPackageById should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Package not found');
      when(
        () => mockGetPackageByIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(packageViewmodelProvider.notifier)
          .getPackageById('p1');

      final state = container.read(packageViewmodelProvider);
      expect(state.status, PackageStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test(
      'getPackagesByVenueId should set loaded state with packages on success',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        when(
          () => mockGetPackagesByVenueIdUsecase(any()),
        ).thenAnswer((_) async => const Right([tPackage]));

        await container
            .read(packageViewmodelProvider.notifier)
            .getPackagesByVenueId('v1');

        final state = container.read(packageViewmodelProvider);
        expect(state.status, PackageStatus.loaded);
        expect(state.packages, [tPackage]);
        expect(state.errorMessage, isNull);
      },
    );

    test('getPackagesByVenueId should set error state on failure', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const failure = ApiFailure(message: 'Failed to fetch packages');
      when(
        () => mockGetPackagesByVenueIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(packageViewmodelProvider.notifier)
          .getPackagesByVenueId('v1');

      final state = container.read(packageViewmodelProvider);
      expect(state.status, PackageStatus.error);
      expect(state.errorMessage, failure.message);
    });
  });
}
