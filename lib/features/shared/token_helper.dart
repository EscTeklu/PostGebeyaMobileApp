import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/alert_dialogs.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/customize/services/api_service.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/shared/settings.dart';
import 'package:synchronized/synchronized.dart';
import 'package:universal_html/js.dart';

mixin TokenHelper {
  static String? _token;
  static final Lock _lock = Lock();

  static Future Function({String? token, int? customerId, String? email})?
      onTokenChanged;
  //
  static Future Function({String? token, int? customerId, String? phone})?
  onTokenOTPChanged;

  static Future reset() async {
    _token = null;
    AppSettings.clear();
    onTokenChanged?.call();
    await askToken(reload: true);
  }
  //for otp login
  static Future<String?> askTokenOTP({
    String? phone,
    String? token,
    int? userId,
    reload = false,
  }) async {
    if (_token != null && !reload) {
      return _token;
    }

    String? token;

    await _lock.synchronized(() async {
      _token = token;
      const storage = FlutterSecureStorage();
      await storage.write(key: "user_token", value: token);

      /*await onTokenOTPChanged?.call(
          token: token, phone: phone, customerId: userId);*/
      await onTokenChanged?.call(
          token: token, email: phone, customerId: userId);
      /*final ApiService apiService = ApiService();

      final response = await apiService.getToken(phone, otp);

      if (response['success']) {
        token = response['token'];


      } else {
        throw Exception('Failed to load slides (status: ${response.toString()})');
      }*/
    });

    return token;
  }

  static Future<String?> askToken({
    String? email,
    String? password,
    reload = false,
  }) async {
    if (_token != null && !reload) {
      return _token;
    }

    String? token;

    await _lock.synchronized(() async {
      final api = FrontendApi(
        dio: Dio(BaseOptions(baseUrl: AppConstants.storeUrl)),
        serializers: standardSerializers,
      ).getAuthenticateApi();

      var requestBuilder = AuthenticateCustomerRequestBuilder();
      requestBuilder.username = email;
      requestBuilder.email = email;
      requestBuilder.password = password;
      requestBuilder.isGuest = email == null;

      var authenticateCustomerRequest = requestBuilder.build();

      final response = await api.apiFrontendAuthenticateGetTokenPost(
          authenticateCustomerRequest: authenticateCustomerRequest);

      debugPrint(response.toString());

      if (response.statusCode == 200) {
        token = response.data!.token;

        _token = token;
        const storage = FlutterSecureStorage();
        await storage.write(key: "user_token", value: token);

        await onTokenChanged?.call(
            token: token, email: email, customerId: response.data?.customerId);
      }
    });

    return token;
  }

  static Future<String?> _loadToken() async {
    const storage = FlutterSecureStorage();

    final token = await _lock.synchronized(() async {
      return await storage.read(key: "user_token");
    });

    if (token == null) {
      _token = null;
      return null;
    }

    _token = token;
    await _lock.synchronized(() async {
      await onTokenChanged?.call(token: token);
    });

    return token;
  }

  static Future<String?> getToken() async {
    _token = _token ?? await _loadToken() ?? await askToken();

    return _token;
  }
}
