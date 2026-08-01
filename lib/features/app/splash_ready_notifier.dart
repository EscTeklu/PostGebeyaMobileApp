import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashReadyNotifier extends ChangeNotifier {
  bool _ready = false;
  bool get ready => _ready;

  void setReady() {
    if (_ready) return;
    _ready = true;
    notifyListeners();
  }
}

final splashReadyNotifierProvider = Provider<SplashReadyNotifier>((ref) {
  return SplashReadyNotifier();
});
