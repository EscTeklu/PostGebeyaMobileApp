import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/customize/util/secure_utils.dart';
import 'package:nopcommerce_mobile/features/app/theme/app_theme_provider.dart';
import 'package:nopcommerce_mobile/utils/exceptions/async_error_logger.dart';
import 'package:nopcommerce_mobile/utils/exceptions/error_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nopcommerce_mobile/nop_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await SecureStorageHelper.clearAll();
  debugPrint("BAHU Cleared");
  final sharedPreferences = await SharedPreferences.getInstance();
  //

  // Create ProviderContainer with any required overrides
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
    observers: [AsyncErrorLogger()],
  );

  final errorLogger = container.read(errorLoggerProvider);
  // Register error handlers. For more info, see: https://docs.flutter.dev/testing/errors
  registerErrorHandlers(errorLogger);
  //
  // Override debugPrint in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      // Suppress ALL logs in release builds
      };
    }
  //
  final emulator = await isEmulator();
  final rooted = await isRooted();
  //final rooted = await RootDetector.isRooted();
  if (emulator || rooted)
  {
    runApp(BlockedApp()); // Show warning screen
    //just to test
    /*runApp(
      UncontrolledProviderScope(
        container: container,
        child: const NopMobileApp(),
      ),
    );*/
  }
  else
  {
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const NopMobileApp(),
        ),
      );// Normal app flow

  }
  //
  // Listen for changes
  /*NetworkGuard.onConnectionChange().listen((result) async {
    final hasInternet = await NetworkGuard.hasInternetAccess();
    print("Internet status changed: $hasInternet");
  });*/

}


void registerErrorHandlers(ErrorLogger errorLogger) {
  // Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    errorLogger.logError(details.exception, details.stack);
  };
  // Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    errorLogger.logError(error, stack);
    return true;
  };
  // Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Ohhh! Sorry '),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          //Center(child: Text(details.toString())),
          //Center(child: Text(details.exceptionAsString())),
          //Center(child: Text(details.stack.toString())),
          Center(child: Text('SomeThing Went Wrong !!!, Please Try Again !!!', style: TextStyle(
            fontSize: 14,
            backgroundColor: Color(0xFFEC1A1A),
          ),)),
        ],
      )
    );
  };
}



class BlockedApp extends StatelessWidget {
  const BlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'This app cannot run on emulators or rooted devices.',
            style: TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
