import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/models/new_product_model.dart';
import 'package:nopcommerce_mobile/customize/models/nivo_slider_item.dart';
//import 'package:nopcommerce_mobile/customize/models/product.dart';
import 'package:nopcommerce_mobile/customize/models/discounted_product.dart';
import 'package:nopcommerce_mobile/customize/models/product_model.dart';

class ApiService {

  String? _sessionCookie;

  Future<List<Product>> getMostSoldProducts() async {
    final response = await http.get(Uri.parse("${AppConstants.storeUrl}api/products/v1/mostsold"));
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load most sold products");
    }
  }

  Future<List<DiscountProduct>> getDiscountedProducts() async {
    final response = await http.get(Uri.parse("${AppConstants.storeUrl}api/products/discounted"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => DiscountProduct.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load discounted products");
    }
  }

  Future<List<NewProductModel>> fetchNewProducts() async {
    final response = await http.get(Uri.parse("${AppConstants.storeUrl}api/products/new"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => NewProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load new products');
    }
  }

  /// Fetches slides from the API
  Future<SlidesResponse> fetchSlides() async {
    final url = Uri.parse("${AppConstants.storeUrl}api-frontend/nivoslider/slides"); // <-- adjust endpoint
    final response = await http.get(url);

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
