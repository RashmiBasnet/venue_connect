import 'package:equatable/equatable.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';

enum BookingStateStatus { initial, loading, loaded, created, error }

class BookingState extends Equatable {
  final BookingStateStatus status;
  final List<BookingEntity> bookings;
  final BookingEntity? selectedBooking;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStateStatus.initial,
    this.bookings = const <BookingEntity>[],
    this.selectedBooking,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStateStatus? status,
    List<BookingEntity>? bookings,
    BookingEntity? selectedBooking,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, selectedBooking, errorMessage];
}
