import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/models/payment_init_response.dart';

//import 'package:dio/adapter.dart';
import 'dart:io';

class PaymentService {
  final String authToken;
  PaymentService(this.authToken);

  var headers = {
    'Cookie': '.Nop.Antiforgery=CfDJ8KFJ0lTsUyhGs1nPm3MGhlnOAoCEuLh9WrU8G11AXalSh6U8nLOKbBiGdfrYNyZyhT3bPkQw4_yDq3aQ6R76TTCjWcXj2avgCU1HcYvb4-K-Db19UjAfSvpwNh1csGRXkIQa02oACTby338Edw5mqTU; .Nop.Culture=c%3Den-US%7Cuic%3Den-US; .Nop.Customer=16f34caa-ac46-4ce8-bba3-9b8c4c8fa6d7; ARRAffinity=81e6e6013f7aa9433508df690722b5f9ceda4674ac62040d9229251e12cb1344'
  };
  var dio = Dio();

  //============new
  Future<PaymentInitResponse> createPayment(String orderGuid) async {
    /*final uri = Uri.parse("${AppConstants.storeUrl}api/ethswitch/create-payment?orderId=$orderGuid");
    final resp = await http.post(
        uri,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'nopcommerce.flutter/v1',
        'Authorization': 'Bearer $authToken',
      },
    );*/
    var resp = await dio.request(
      '${AppConstants.storeUrl}api/ethswitch/create-payment?orderId=$orderGuid',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
    );
    if (resp.statusCode == 200) {
      //final map = jsonDecode(resp.data) as Map<String, dynamic>;
      final map = resp.data as Map<String, dynamic>;
      return PaymentInitResponse.fromJson(map);
    }
    return PaymentInitResponse(success: false, message: "HTTP ${resp.statusCode}", paymentUrl: "", orderId: "", txnRef: "");
  }

  //new end
  Future<Map<String, dynamic>> initiatePayment(String amount, String orderId) async {
    /*final response = await http.post(
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
    );*/
    var response = await dio.request(
      '${AppConstants.storeUrl}api/ethswitch/initiate-payment',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: jsonEncode({
        'amount': amount,
        "OrderNumber": orderId
      }),
    );
    //print(response.body);
    if (response.statusCode == 200) {
      //return jsonDecode(response.data) as Map<String, dynamic>;
      final data = response.data;
      if (data is String)
      {
        return jsonDecode(data) as Map<String, dynamic>;
      } else
      {
        return data as Map<String, dynamic>;
      }
    } else {
      throw Exception('Failed to initiate payment: ${response.statusCode} ${response.data}');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String orderId) async {
    /*final response = await http.get(
      Uri.parse('${AppConstants.storeUrl}api/ethswitch/verify?orderId=$orderId'),
    );*/
    var response = await dio.request(
      '${AppConstants.storeUrl}api/ethswitch/verify?orderId=$orderId',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      //return jsonDecode(response.data) as Map<String, dynamic>;
      final data = response.data;
      if (data is String)
      {
        return jsonDecode(data) as Map<String, dynamic>;
      } else
      {
        return data as Map<String, dynamic>;
      }
    } else {
      throw Exception('Failed to verify payment: ${response.statusCode} ${response.data}');
    }
  }


  Dio createDio() {
    final dio = Dio();

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return dio;
  }

}
