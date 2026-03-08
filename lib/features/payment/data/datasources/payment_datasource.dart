import 'package:venue_connect/features/payment/data/models/payment_api_model.dart';

abstract interface class IPaymentRemoteDatasource {
  Future<Map<String, dynamic>> initiateKhaltiPayment({
    required String bookingId,
    required int amount,
    required String returnUrl,
  });

  Future<Map<String, dynamic>> verifyKhaltiPayment({
    required String bookingId,
    required String pidx,
  });

  Future<List<PaymentApiModel>> getUserPayments({
    int? page,
    int? size,
    String? status,
  });

  Future<PaymentApiModel?> getPaymentByBookingId(String bookingId);
}
