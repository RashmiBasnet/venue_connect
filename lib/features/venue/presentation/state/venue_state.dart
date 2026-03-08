import 'package:equatable/equatable.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

enum VenueStatus { initial, loading, loaded, error }

class VenueState extends Equatable {
  final VenueStatus status;
  final List<VenueEntity> venues;
  final VenueEntity? selectedVenue;
  final String? errorMessage;

  const VenueState({
    this.status = VenueStatus.initial,
    this.venues = const <VenueEntity>[],
    this.selectedVenue,
    this.errorMessage,
  });

  VenueState copyWith({
    VenueStatus? status,
    List<VenueEntity>? venues,
    VenueEntity? selectedVenue,
    String? errorMessage,
  }) {
    return VenueState(
      status: status ?? this.status,
      venues: venues ?? this.venues,
      selectedVenue: selectedVenue ?? this.selectedVenue,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, venues, selectedVenue, errorMessage];
}
