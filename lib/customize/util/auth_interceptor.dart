import 'package:dio/dio.dart';
import 'package:nopcommerce_mobile/customize/util/secure_utils.dart';
import 'package:nopcommerce_mobile/features/authentication/data/auth_repository.dart';
//import 'authenticate_repository.dart';
//import 'package:nopcommerce_mobile/utils/secure_storage_helper.dart';
import 'dart:convert';

bool isTokenExpired(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return true;
  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final exp = (json.decode(payload) as Map<String, dynamic>)['exp'] as int?;
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return exp == null || exp < now;
}

class AuthInterceptor extends Interceptor {
  final AuthenticateRepository authRepo;
  AuthInterceptor(this.authRepo);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var token = await SecureStorageHelper.readDecrypted("user_token");

    if (token != null && isTokenExpired(token)) {
      token = await authRepo.refreshAccessToken();
    }

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
