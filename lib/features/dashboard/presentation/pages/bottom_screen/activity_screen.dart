import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/presentation/pages/booking_detail_screen.dart';
import 'package:venue_connect/features/booking/presentation/state/booking_state.dart';
import 'package:venue_connect/features/booking/presentation/view_model/booking_viewmodel.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

enum _ActivityFilter { ongoing, pending, past }

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with WidgetsBindingObserver {
  _ActivityFilter _selectedFilter = _ActivityFilter.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(bookingViewmodelProvider.notifier).getMyBookings();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onRefresh());
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(bookingViewmodelProvider.notifier).getMyBookings();
  }

  Future<void> _openBookingDetails(BookingEntity booking) async {
    final bookingId = booking.bookingId;
    if (bookingId == null || bookingId.trim().isEmpty) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(bookingId: bookingId),
      ),
    );

    if (!mounted) return;
    await _onRefresh();
  }

  List<BookingEntity> _filterBookings(
    List<BookingEntity> bookings,
    _ActivityFilter filter,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isPastByDate(BookingEntity booking) {
      final date = DateTime(
        booking.eventDate.year,
        booking.eventDate.month,
        booking.eventDate.day,
      );
      return date.isBefore(today);
    }

    bool isPast(BookingEntity booking) =>
        booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.completed ||
        isPastByDate(booking);

    return bookings.where((booking) {
      switch (filter) {
        case _ActivityFilter.pending:
          return booking.status == BookingStatus.pending;
        case _ActivityFilter.ongoing:
          return booking.status == BookingStatus.confirmed && !isPast(booking);
        case _ActivityFilter.past:
          return isPast(booking);
      }
    }).toList()..sort((a, b) => b.eventDate.compareTo(a.eventDate));
  }

  int _countForFilter(List<BookingEntity> all, _ActivityFilter filter) =>
      _filterBookings(all, filter).length;

  String _filterLabel(_ActivityFilter filter) {
    switch (filter) {
      case _ActivityFilter.ongoing:
        return 'Ongoing';
      case _ActivityFilter.pending:
        return 'Pending';
      case _ActivityFilter.past:
        return 'Past';
    }
  }

  String _formatDate(DateTime date) {
    const weekDays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final dayName = weekDays[date.weekday - 1];
    final monthName = months[date.month - 1];
    final dd = date.day.toString().padLeft(2, '0');

    return '$dayName, $dd $monthName ${date.year}';
  }

  String _formatMoney(double amount) {
    if (amount == amount.toInt()) {
      return 'NPR ${amount.toInt()}';
    }
    return 'NPR ${amount.toStringAsFixed(2)}';
  }

  String _addressLine(BookingEntity booking) {
    final venue = booking.venue;
    if (venue == null) return 'Address not available';

    final parts = <String>[
      if ((venue.address.area ?? '').trim().isNotEmpty)
        venue.address.area!.trim(),
      venue.address.city,
    ];

    return parts.isEmpty ? 'Address not available' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewmodelProvider);
    final allBookings = state.bookings;
    final filteredBookings = _filterBookings(allBookings, _selectedFilter);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                fontFamily: 'Poppins Bold',
                fontSize: 30,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Track your pending, upcoming, and past bookings.',
              style: TextStyle(
                fontFamily: 'Poppins Regular',
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _ActivityFilter.values.map((filter) {
                final selected = filter == _selectedFilter;
                final count = _countForFilter(allBookings, filter);

                return ChoiceChip(
                  selected: selected,
                  label: Text('${_filterLabel(filter)} ($count)'),
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  selectedColor: const Color(0xFF0F172A),
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins Medium',
                    fontSize: 13,
                    color: selected ? Colors.white : const Color(0xFF334155),
                  ),
                  backgroundColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (state.status == BookingStateStatus.loading &&
                allBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.status == BookingStateStatus.error &&
                allBookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  state.errorMessage ?? 'Failed to fetch bookings',
                  style: const TextStyle(
                    fontFamily: 'Poppins Medium',
                    fontSize: 13,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              )
            else if (filteredBookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x1A000000)),
                ),
                child: Text(
                  'No ${_filterLabel(_selectedFilter).toLowerCase()} bookings found.',
                  style: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
              )
            else
              ...filteredBookings.map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _BookingCard(
                    booking: booking,
                    eventDateText: _formatDate(booking.eventDate),
                    addressText: _addressLine(booking),
                    totalText: _formatMoney(booking.totalPrice),
                    onViewDetails: () => _openBookingDetails(booking),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final String eventDateText;
  final String addressText;
  final String totalText;
  final Future<void> Function() onViewDetails;

  const _BookingCard({
    required this.booking,
    required this.eventDateText,
    required this.addressText,
    required this.totalText,
    required this.onViewDetails,
  });

  Color _statusBg(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFEF3C7);
      case BookingStatus.confirmed:
        return const Color(0xFFDCFCE7);
      case BookingStatus.cancelled:
        return const Color(0xFFFEE2E2);
      case BookingStatus.completed:
        return const Color(0xFFE0E7FF);
    }
  }

  Color _statusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFF92400E);
      case BookingStatus.confirmed:
        return const Color(0xFF166534);
      case BookingStatus.cancelled:
        return const Color(0xFFB91C1C);
      case BookingStatus.completed:
        return const Color(0xFF1D4ED8);
    }
  }

  Color _paymentBg(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return const Color(0xFFF1F5F9);
      case PaymentStatus.paid:
        return const Color(0xFFDCFCE7);
      case PaymentStatus.refunded:
        return const Color(0xFFFEE2E2);
    }
  }

  Color _paymentText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return const Color(0xFF334155);
      case PaymentStatus.paid:
        return const Color(0xFF166534);
      case PaymentStatus.refunded:
        return const Color(0xFFB91C1C);
    }
  }

  Widget _badge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins Medium',
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venue = booking.venue;
    final imageName = venue?.images.isNotEmpty == true
        ? venue!.images.first
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: imageName == null
                  ? Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF94A3B8),
                        size: 30,
                      ),
                    )
                  : Image.network(
                      ApiEndpoints.venueImage(imageName),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF94A3B8),
                          size: 30,
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue?.name ?? 'Venue',
                  style: const TextStyle(
                    fontFamily: 'Poppins SemiBold',
                    fontSize: 19,
                    color: Color(0xFF0F172A),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  addressText,
                  style: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge(
                      text: booking.status.name,
                      backgroundColor: _statusBg(booking.status),
                      textColor: _statusText(booking.status),
                    ),
                    _badge(
                      text: booking.paymentStatus.name,
                      backgroundColor: _paymentBg(booking.paymentStatus),
                      textColor: _paymentText(booking.paymentStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _detailRow('Event Date', eventDateText),
                _detailRow('Time', '${booking.startTime} - ${booking.endTime}'),
                _detailRow('Guests', '${booking.guests}'),
                _detailRow('Total', totalText),
                _detailRow('Package', booking.package?.name ?? 'No package'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: booking.bookingId == null
                        ? null
                        : () async {
                            await onViewDetails();
                          },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      foregroundColor: const Color(0xFF1F2937),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'View booking details',
                      style: TextStyle(
                        fontFamily: 'Poppins Medium',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _detailRow(String label, String value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins Regular',
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins Medium',
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    ),
  );
}
