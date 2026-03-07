import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_client.dart';
import 'package:venue_connect/features/payment/data/datasources/payment_datasource.dart';
import 'package:venue_connect/features/payment/data/models/payment_api_model.dart';

final paymentRemoteDatasourceProvider = Provider<PaymentRemoteDatasource>((ref) {
  return PaymentRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class PaymentRemoteDatasource implements IPaymentRemoteDatasource {
  final ApiClient _apiClient;

  PaymentRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> initiateKhaltiPayment({
    required String bookingId,
    required int amount,
    required String returnUrl,
  }) async {
    final response = await _apiClient.post(
      '/payments/khalti/initiate',
      data: {
        'bookingId': bookingId,
        'amount': amount,
        'returnUrl': returnUrl,
      },
    );

    if (response.data['success'] == true) {
      return (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
    }

    throw Exception(response.data['message'] ?? 'Failed to initiate payment');
  }

  @override
  Future<Map<String, dynamic>> verifyKhaltiPayment({
    required String bookingId,
    required String pidx,
  }) async {
    final response = await _apiClient.post(
      '/payments/khalti/verify',
      data: {'bookingId': bookingId, 'pidx': pidx},
    );

    if (response.data['success'] == true) {
      return (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
    }

    throw Exception(response.data['message'] ?? 'Failed to verify payment');
  }

  @override
  Future<List<PaymentApiModel>> getUserPayments({
    int? page,
    int? size,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (size != null) 'size': size,
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
    };

    final response = await _apiClient.get(
      '/payments/user',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    if (response.data['success'] == true) {
      final data = (response.data['data'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>();
      return data.map(PaymentApiModel.fromJson).toList();
    }

    return <PaymentApiModel>[];
  }

  @override
  Future<PaymentApiModel?> getPaymentByBookingId(String bookingId) async {
    final response = await _apiClient.get('/payments/booking/$bookingId');

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return PaymentApiModel.fromJson(data);
    }

    return null;
  }
}
