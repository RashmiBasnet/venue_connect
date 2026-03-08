import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/package/data/repositories/package_repository.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';

class GetPackagesByVenueIdUsecaseParams extends Equatable {
  final String venueId;

  const GetPackagesByVenueIdUsecaseParams({required this.venueId});

  @override
  List<Object?> get props => [venueId];
}

final getPackagesByVenueIdUsecaseProvider =
    Provider<GetPackagesByVenueIdUsecase>((ref) {
      return GetPackagesByVenueIdUsecase(
        packageRepository: ref.read(packageRepositoryProvider),
      );
    });

class GetPackagesByVenueIdUsecase
    implements
        UsecaseWithParams<
          List<PackageEntity>,
          GetPackagesByVenueIdUsecaseParams
        > {
  final IPackageRepository _packageRepository;

  GetPackagesByVenueIdUsecase({required IPackageRepository packageRepository})
    : _packageRepository = packageRepository;

  @override
  Future<Either<Failure, List<PackageEntity>>> call(
    GetPackagesByVenueIdUsecaseParams params,
  ) {
    return _packageRepository.getPackagesByVenueId(params.venueId);
  }
}
