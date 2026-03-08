import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/features/package/domain/usecases/get_all_packages_usecase.dart';
import 'package:venue_connect/features/package/domain/usecases/get_package_by_id_usecase.dart';
import 'package:venue_connect/features/package/domain/usecases/get_packages_by_venue_id_usecase.dart';
import 'package:venue_connect/features/package/presentation/state/package_state.dart';

final packageViewmodelProvider =
    NotifierProvider<PackageViewmodel, PackageState>(() => PackageViewmodel());

class PackageViewmodel extends Notifier<PackageState> {
  late final GetAllPackagesUsecase _getAllPackagesUsecase;
  late final GetPackageByIdUsecase _getPackageByIdUsecase;
  late final GetPackagesByVenueIdUsecase _getPackagesByVenueIdUsecase;

  @override
  PackageState build() {
    _getAllPackagesUsecase = ref.read(getAllPackagesUsecaseProvider);
    _getPackageByIdUsecase = ref.read(getPackageByIdUsecaseProvider);
    _getPackagesByVenueIdUsecase = ref.read(
      getPackagesByVenueIdUsecaseProvider,
    );
    return const PackageState();
  }

  Future<void> getAllPackages({int? page, int? size, String? search}) async {
    state = state.copyWith(status: PackageStatus.loading, errorMessage: null);

    final result = await _getAllPackagesUsecase(
      GetAllPackagesUsecaseParams(page: page, size: size, search: search),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PackageStatus.error,
          errorMessage: failure.message,
        );
      },
      (packages) {
        state = state.copyWith(
          status: PackageStatus.loaded,
          packages: packages,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getPackageById(String packageId) async {
    state = state.copyWith(status: PackageStatus.loading, errorMessage: null);

    final result = await _getPackageByIdUsecase(
      GetPackageByIdUsecaseParams(packageId: packageId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PackageStatus.error,
          errorMessage: failure.message,
        );
      },
      (package) {
        state = state.copyWith(
          status: PackageStatus.loaded,
          selectedPackage: package,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getPackagesByVenueId(String venueId) async {
    state = state.copyWith(status: PackageStatus.loading, errorMessage: null);

    final result = await _getPackagesByVenueIdUsecase(
      GetPackagesByVenueIdUsecaseParams(venueId: venueId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PackageStatus.error,
          errorMessage: failure.message,
        );
      },
      (packages) {
        state = state.copyWith(
          status: PackageStatus.loaded,
          packages: packages,
          errorMessage: null,
        );
      },
    );
  }
}
