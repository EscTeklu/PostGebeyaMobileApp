//

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkGuard {
  /// Check if device has any network connection (WiFi/Mobile).
  static Future<bool> isConnectedToNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Verify actual internet access by pinging a reliable host.
  static Future<bool> hasInternetAccess() async {
    if (!await isConnectedToNetwork()) return false;

    try {
      final result = await InternetAddress.lookup('https://postgebeya.ethio.post');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Listen for connectivity changes in real-time.
  static Stream<List<ConnectivityResult>> onConnectionChange() {
    return Connectivity().onConnectivityChanged;
  }
}

class NoInternetApp extends StatelessWidget {
  const NoInternetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'No Stable Connection. Please check your network.',
            style: TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}