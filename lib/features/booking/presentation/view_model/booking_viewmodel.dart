import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';
import 'package:venue_connect/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_booking_by_id_usecase.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:venue_connect/features/booking/presentation/state/booking_state.dart';

final bookingViewmodelProvider =
    NotifierProvider<BookingViewmodel, BookingState>(() => BookingViewmodel());

class BookingViewmodel extends Notifier<BookingState> {
  late final CreateBookingUsecase _createBookingUsecase;
  late final GetMyBookingsUsecase _getMyBookingsUsecase;
  late final GetMyBookingByIdUsecase _getMyBookingByIdUsecase;

  @override
  BookingState build() {
    _createBookingUsecase = ref.read(createBookingUsecaseProvider);
    _getMyBookingsUsecase = ref.read(getMyBookingsUsecaseProvider);
    _getMyBookingByIdUsecase = ref.read(getMyBookingByIdUsecaseProvider);
    return const BookingState();
  }

  Future<void> createBooking(CreateBookingEntity request) async {
    state = state.copyWith(
      status: BookingStateStatus.loading,
      errorMessage: null,
    );

    final result = await _createBookingUsecase(request);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (booking) {
        state = state.copyWith(
          status: BookingStateStatus.created,
          selectedBooking: booking,
          bookings: [booking, ...state.bookings],
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getMyBookings() async {
    state = state.copyWith(
      status: BookingStateStatus.loading,
      errorMessage: null,
    );

    final result = await _getMyBookingsUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (bookings) {
        state = state.copyWith(
          status: BookingStateStatus.loaded,
          bookings: bookings,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getMyBookingById(String bookingId) async {
    state = state.copyWith(
      status: BookingStateStatus.loading,
      errorMessage: null,
    );

    final result = await _getMyBookingByIdUsecase(
      GetMyBookingByIdUsecaseParams(bookingId: bookingId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (booking) {
        state = state.copyWith(
          status: BookingStateStatus.loaded,
          selectedBooking: booking,
          errorMessage: null,
        );
      },
    );
  }

  void clearSelectedBooking() {
    state = state.copyWith(selectedBooking: null, errorMessage: null);
  }
}
