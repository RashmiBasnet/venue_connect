import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/booking/domain/entities/booking_entity.dart';
import 'package:venue_connect/features/booking/domain/usecases/get_my_booking_by_id_usecase.dart';
import 'package:venue_connect/features/payment/domain/entities/payment_entity.dart';
import 'package:venue_connect/features/payment/presentation/state/payment_state.dart';
import 'package:venue_connect/features/payment/presentation/view_model/payment_viewmodel.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen>
    with WidgetsBindingObserver {
  late Future<BookingEntity> _bookingFuture;
  bool _isPaying = false;
  bool _isVerifyingPayment = false;
  bool _paymentFlowStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bookingFuture = _fetchBooking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _paymentFlowStarted &&
        !_isVerifyingPayment) {
      _syncPaymentStatus(showFeedback: false);
    }
  }

  Future<BookingEntity> _fetchBooking() async {
    final usecase = ref.read(getMyBookingByIdUsecaseProvider);
    final result = await usecase(
      GetMyBookingByIdUsecaseParams(bookingId: widget.bookingId),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (booking) => booking,
    );
  }

  Future<void> _onRefresh() async {
    final next = _fetchBooking();
    setState(() {
      _bookingFuture = next;
    });
    await next;
  }

  Future<void> _payWithKhalti(BookingEntity booking) async {
    final bookingId = booking.bookingId;
    if (bookingId == null || bookingId.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking ID is missing')));
      return;
    }

    setState(() {
      _isPaying = true;
    });

    await ref.read(paymentViewmodelProvider.notifier).initiateKhaltiPayment(
      bookingId: bookingId,
      amount: booking.totalPrice.round(),
      returnUrl: 'https://example.com/khalti-return',
    );

    if (!mounted) return;

    final paymentState = ref.read(paymentViewmodelProvider);
    final payload = paymentState.paymentPayload;
    final paymentUrl = payload?['paymentUrl'] as String?;

    setState(() {
      _isPaying = false;
    });

    if (paymentState.status == PaymentStateStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentState.errorMessage ?? 'Failed to initiate payment'),
        ),
      );
      return;
    }

    if (paymentUrl == null || paymentUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment URL was not returned by server')),
      );
      return;
    }

    final uri = Uri.tryParse(paymentUrl);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid payment URL')));
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showPaymentUrlFallback(paymentUrl);
      } else if (launched) {
        _paymentFlowStarted = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Complete payment in Khalti, then return to this app.',
              ),
            ),
          );
        }
      }
    } on PlatformException {
      if (!mounted) return;
      _showPaymentUrlFallback(paymentUrl);
    } catch (_) {
      if (!mounted) return;
      _showPaymentUrlFallback(paymentUrl);
    }
  }

  Future<void> _syncPaymentStatus({bool showFeedback = true}) async {
    final bookingId = widget.bookingId;
    if (bookingId.trim().isEmpty) return;

    if (mounted) {
      setState(() {
        _isVerifyingPayment = true;
      });
    }

    await ref.read(paymentViewmodelProvider.notifier).getPaymentByBookingId(
      bookingId,
    );

    if (!mounted) return;

    var paymentState = ref.read(paymentViewmodelProvider);
    final payment = paymentState.selectedPayment;

    if (paymentState.status == PaymentStateStatus.error || payment == null) {
      setState(() {
        _isVerifyingPayment = false;
      });
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentState.errorMessage ?? 'Payment record not found yet',
            ),
          ),
        );
      }
      return;
    }

    if (payment.status == PaymentRecordStatus.pending &&
        (payment.pidx ?? '').trim().isNotEmpty) {
      await ref.read(paymentViewmodelProvider.notifier).verifyKhaltiPayment(
        bookingId: bookingId,
        pidx: payment.pidx!.trim(),
      );
      if (!mounted) return;
      paymentState = ref.read(paymentViewmodelProvider);
    }

    if (paymentState.status == PaymentStateStatus.error) {
      setState(() {
        _isVerifyingPayment = false;
      });
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentState.errorMessage ?? 'Payment verification failed',
            ),
          ),
        );
      }
      return;
    }

    await _onRefresh();
    if (!mounted) return;

    setState(() {
      _isVerifyingPayment = false;
    });
    _paymentFlowStarted = false;

    if (showFeedback) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment status updated')),
      );
    }
  }

  void _showPaymentUrlFallback(String paymentUrl) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Open Khalti Link',
                style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Auto-open failed. Copy this URL and open it in your browser.',
                style: TextStyle(fontFamily: 'Poppins Regular', fontSize: 13),
              ),
              const SizedBox(height: 12),
              SelectableText(
                paymentUrl,
                style: const TextStyle(
                  fontFamily: 'Poppins Regular',
                  fontSize: 12,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(this.context);
                    await Clipboard.setData(ClipboardData(text: paymentUrl));
                    if (!context.mounted) return;
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Payment URL copied')),
                    );
                  },
                  child: const Text('Copy Payment URL'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontFamily: 'Poppins SemiBold'),
        ),
      ),
      body: FutureBuilder<BookingEntity>(
        future: _bookingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins Medium',
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final booking = snapshot.data!;
          final venue = booking.venue;
          final imageName = venue?.images.isNotEmpty == true
              ? venue!.images.first
              : null;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'Booking ID: ${booking.bookingId ?? '-'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: SizedBox(
                          height: 210,
                          width: double.infinity,
                          child: imageName == null
                              ? Container(
                                  color: const Color(0xFFF1F5F9),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFF94A3B8),
                                    size: 32,
                                  ),
                                )
                              : Image.network(
                                  ApiEndpoints.venueImage(imageName),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: const Color(0xFFF1F5F9),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          color: Color(0xFF94A3B8),
                                          size: 32,
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        venue?.name ?? 'Venue',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins SemiBold',
                                          fontSize: 30,
                                          color: Color(0xFF0F172A),
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _addressLine(booking),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins Regular',
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusBadge(status: booking.status),
                                const SizedBox(width: 6),
                                _PaymentBadge(status: booking.paymentStatus),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _detailBox(
                                    'Event Date',
                                    _formatDate(booking.eventDate),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _detailBox(
                                    'Time',
                                    '${booking.startTime} - ${booking.endTime}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _detailBox(
                                    'Guests',
                                    '${booking.guests}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _detailBox(
                                    'Package',
                                    booking.package?.name ?? 'No package',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _detailBox(
                                    'Price / plate',
                                    _formatMoney(booking.pricePerPlate),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _detailBox(
                                    'Total',
                                    _formatMoney(booking.totalPrice),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    booking.paymentStatus ==
                                        PaymentStatus.unpaid
                                    ? (_isPaying || _isVerifyingPayment
                                          ? null
                                          : () => _payWithKhalti(booking))
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB28A4E),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFFE2E8F0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  booking.paymentStatus == PaymentStatus.unpaid
                                      ? (_isPaying
                                            ? 'Redirecting to Khalti...'
                                            : _isVerifyingPayment
                                            ? 'Checking payment status...'
                                            : 'Pay with Khalti')
                                      : 'Payment Completed',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins SemiBold',
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            if (booking.paymentStatus == PaymentStatus.unpaid)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'You will be redirected to Khalti to complete payment.',
                                  style: TextStyle(
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            if (booking.paymentStatus == PaymentStatus.unpaid)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _isPaying || _isVerifyingPayment
                                        ? null
                                        : () => _syncPaymentStatus(),
                                    child: Text(
                                      _isVerifyingPayment
                                          ? 'Checking...'
                                          : 'I have completed payment',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1F2937),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Activity',
                      style: TextStyle(
                        fontFamily: 'Poppins Medium',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins Regular',
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins SemiBold',
              fontSize: 20,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  Color get _bg {
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

  Color get _text {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          fontFamily: 'Poppins Medium',
          fontSize: 12,
          color: _text,
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final PaymentStatus status;

  const _PaymentBadge({required this.status});

  Color get _bg {
    switch (status) {
      case PaymentStatus.unpaid:
        return const Color(0xFFF1F5F9);
      case PaymentStatus.paid:
        return const Color(0xFFDCFCE7);
      case PaymentStatus.refunded:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get _text {
    switch (status) {
      case PaymentStatus.unpaid:
        return const Color(0xFF334155);
      case PaymentStatus.paid:
        return const Color(0xFF166534);
      case PaymentStatus.refunded:
        return const Color(0xFFB91C1C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          fontFamily: 'Poppins Medium',
          fontSize: 12,
          color: _text,
        ),
      ),
    );
  }
}
