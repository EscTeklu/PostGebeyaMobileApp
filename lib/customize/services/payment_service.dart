import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/models/payment_init_response.dart';

class PaymentService {
  final String authToken;
  PaymentService(this.authToken);

  //============new
  Future<PaymentInitResponse> createPayment(String orderGuid) async {
    final uri = Uri.parse("${AppConstants.storeUrl}api/ethswitch/create-payment?orderId=$orderGuid");
    final resp = await http.post(
        uri,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'nopcommerce.flutter/v1',
        'Authorization': 'Bearer $authToken',
      },
    );
    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      return PaymentInitResponse.fromJson(map);
    }
    return PaymentInitResponse(success: false, message: "HTTP ${resp.statusCode}", paymentUrl: "", orderId: "", txnRef: "");
  }

  //new end
  Future<Map<String, dynamic>> initiatePayment(String amount, String orderId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.storeUrl}api/ethswitch/initiate-payment'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'nopcommerce.flutter/v1',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'amount': amount,
        "OrderNumber": orderId
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to initiate payment: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String orderId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.storeUrl}api/ethswitch/verify?orderId=$orderId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to verify payment: ${response.statusCode} ${response.body}');
    }
  }
}
