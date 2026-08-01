import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nopcommerce_mobile/customize/models/banner_model.dart';

class ApiServiceSlider {
  static const String baseUrl = 'https://postgebeya.ethio.post/api';

  Future<List<BannerCarousel>> getSliders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pavilion/sliders'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization if needed later
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BannerCarousel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sliders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sliders: $e');
    }
  }
}