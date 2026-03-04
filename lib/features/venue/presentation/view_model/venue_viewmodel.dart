import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_all_venues_usecase.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_venue_by_id_usecase.dart';
import 'package:venue_connect/features/venue/presentation/state/venue_state.dart';

final venueViewmodelProvider = NotifierProvider<VenueViewmodel, VenueState>(
  () => VenueViewmodel(),
);

class VenueViewmodel extends Notifier<VenueState> {
  late final GetAllVenuesUsecase _getAllVenuesUsecase;
  late final GetVenueByIdUsecase _getVenueByIdUsecase;

  @override
  VenueState build() {
    _getAllVenuesUsecase = ref.read(getAllVenuesUsecaseProvider);
    _getVenueByIdUsecase = ref.read(getVenueByIdUsecaseProvider);
    return const VenueState();
  }

  Future<void> getAllVenues() async {
    state = state.copyWith(status: VenueStatus.loading, errorMessage: null);

    final result = await _getAllVenuesUsecase();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: VenueStatus.error,
          errorMessage: failure.message,
        );
      },
      (venues) {
        state = state.copyWith(
          status: VenueStatus.loaded,
          venues: venues,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getVenueById(String venueId) async {
    state = state.copyWith(status: VenueStatus.loading, errorMessage: null);

    final result = await _getVenueByIdUsecase(
      GetVenueByIdUsecaseParams(venueId: venueId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: VenueStatus.error,
          errorMessage: failure.message,
        );
      },
      (venue) {
        state = state.copyWith(
          status: VenueStatus.loaded,
          selectedVenue: venue,
          errorMessage: null,
        );
      },
    );
  }
}
