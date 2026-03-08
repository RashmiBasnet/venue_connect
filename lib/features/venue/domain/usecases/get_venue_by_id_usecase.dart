import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/venue/data/repositories/venue_repository.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/repositories/venue_repository.dart';

class GetVenueByIdUsecaseParams extends Equatable {
  final String venueId;

  const GetVenueByIdUsecaseParams({required this.venueId});

  @override
  List<Object?> get props => [venueId];
}

final getVenueByIdUsecaseProvider = Provider<GetVenueByIdUsecase>((ref) {
  return GetVenueByIdUsecase(
    venueRepository: ref.read(venueRepositoryProvider),
  );
});

class GetVenueByIdUsecase
    implements UsecaseWithParams<VenueEntity, GetVenueByIdUsecaseParams> {
  final IVenueRepository _venueRepository;

  GetVenueByIdUsecase({required IVenueRepository venueRepository})
    : _venueRepository = venueRepository;

  @override
  Future<Either<Failure, VenueEntity>> call(GetVenueByIdUsecaseParams params) {
    return _venueRepository.getVenueById(params.venueId);
  }
}
