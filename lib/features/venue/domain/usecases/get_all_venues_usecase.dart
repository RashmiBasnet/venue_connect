import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/usecases/app_usecase.dart';
import 'package:venue_connect/features/venue/data/repositories/venue_repository.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/repositories/venue_repository.dart';

final getAllVenuesUsecaseProvider = Provider<GetAllVenuesUsecase>((ref) {
  return GetAllVenuesUsecase(
    venueRepository: ref.read(venueRepositoryProvider),
  );
});

class GetAllVenuesUsecase implements UsecaseWithoutParams<List<VenueEntity>> {
  final IVenueRepository _venueRepository;

  GetAllVenuesUsecase({required IVenueRepository venueRepository})
    : _venueRepository = venueRepository;

  @override
  Future<Either<Failure, List<VenueEntity>>> call() {
    return _venueRepository.getAllVenues();
  }
}
