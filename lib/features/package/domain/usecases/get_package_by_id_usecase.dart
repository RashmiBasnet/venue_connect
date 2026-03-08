import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/package/data/repositories/package_repository.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';

class GetPackageByIdUsecaseParams extends Equatable {
  final String packageId;

  const GetPackageByIdUsecaseParams({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

final getPackageByIdUsecaseProvider = Provider<GetPackageByIdUsecase>((ref) {
  return GetPackageByIdUsecase(
    packageRepository: ref.read(packageRepositoryProvider),
  );
});

class GetPackageByIdUsecase
    implements UsecaseWithParams<PackageEntity, GetPackageByIdUsecaseParams> {
  final IPackageRepository _packageRepository;

  GetPackageByIdUsecase({required IPackageRepository packageRepository})
    : _packageRepository = packageRepository;

  @override
  Future<Either<Failure, PackageEntity>> call(
    GetPackageByIdUsecaseParams params,
  ) {
    return _packageRepository.getPackageById(params.packageId);
  }
}
