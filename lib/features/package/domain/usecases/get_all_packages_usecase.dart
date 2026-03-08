import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/package/data/repositories/package_repository.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/repositories/package_repository.dart';

class GetAllPackagesUsecaseParams extends Equatable {
  final int? page;
  final int? size;
  final String? search;

  const GetAllPackagesUsecaseParams({this.page, this.size, this.search});

  @override
  List<Object?> get props => [page, size, search];
}

final getAllPackagesUsecaseProvider = Provider<GetAllPackagesUsecase>((ref) {
  return GetAllPackagesUsecase(
    packageRepository: ref.read(packageRepositoryProvider),
  );
});

class GetAllPackagesUsecase
    implements
        UsecaseWithParams<List<PackageEntity>, GetAllPackagesUsecaseParams> {
  final IPackageRepository _packageRepository;

  GetAllPackagesUsecase({required IPackageRepository packageRepository})
    : _packageRepository = packageRepository;

  @override
  Future<Either<Failure, List<PackageEntity>>> call(
    GetAllPackagesUsecaseParams params,
  ) {
    return _packageRepository.getAllPackages(
      page: params.page,
      size: params.size,
      search: params.search,
    );
  }
}
