import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as https;
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/models/nivo_slider_item.dart';
import 'package:nopcommerce_mobile/customize/models/product_model.dart';

class ApiService {

  var headers = {
    'Cookie': '.Nop.Culture=c%3Den-US%7Cuic%3Den-US; .Nop.Customer=16f34caa-ac46-4ce8-bba3-9b8c4c8fa6d7; ARRAffinity=81e6e6013f7aa9433508df690722b5f9ceda4674ac62040d9229251e12cb1344'
  };
  var dio = Dio();

  Future<List<Product>> getMostSoldProducts() async {
    var response = await dio.request(
      '${AppConstants.storeUrl}api/data/v1/mostsold',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      print(json.encode(response.data));
      // Ensure response.data is a List
      final data = response.data as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load most sold products");
    }
  }

  Future<List<Product>> getDiscountedProducts() async {
    var response = await dio.request(
      '${AppConstants.storeUrl}api/data/v1/discounted',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      print(json.encode(response.data));
      // Ensure response.data is a List
      final data = response.data as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load most sold products");
    }
  }

  Future<List<Product>> fetchNewProducts() async {
    var response = await dio.request(
      '${AppConstants.storeUrl}api/data/v1/new',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      print(json.encode(response.data));
      // Ensure response.data is a List
      final data = response.data as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load most sold products");
    }
  }

  /// Fetches slides from the API
  Future<SlidesResponse> fetchSlides() async {
    final url = Uri.parse("${AppConstants.storeUrl}api/data/slides"); // <-- adjust endpoint
    final response = await https.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SlidesResponse.fromJson(data);
    } else {
      throw Exception('Failed to load slides (status: ${response.statusCode})');
    }
  }
  //for phone login
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('${AppConstants.storeUrl}api/phoneotp/send'),
      headers: {
        'Content-Type': 'application/json',
        //if (_sessionCookie != null) 'Cookie': _sessionCookie!,
      },
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );
    //_sessionCookie = response.headers['set-cookie'];
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send OTP: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('${AppConstants.storeUrl}api/phoneotp/verify'),
      headers: {
        'Content-Type': 'application/json',
        //if (_sessionCookie != null) 'Cookie': _sessionCookie!,
      },
      body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify OTP: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getToken(
    String? phoneNumber,
    String? otp,
  ) async {
    //await _loadToken();
    final body = <String, String>{};
    if (phoneNumber != null) {
      body['phoneNumber'] = phoneNumber;
    }
    if (otp != null) {
      body['otp'] = otp;
    }

    final response = await http.post(
      Uri.parse('${AppConstants.storeUrl}/phoneotp/token'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      /*if (responseData['token'] != null) {
        await _saveToken(responseData['token']);
      }*/
      return responseData;
    } else {
      throw Exception('Failed to get token: ${response.statusCode} - ${response.body}');
    }
  }

}
