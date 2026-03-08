import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final shakeServiceProvider = Provider<ShakeService>((ref) {
  final service = ShakeService();
  ref.onDispose(service.stopListening);
  return service;
});

class ShakeService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _isAvailable = true;
  int _lastShakeTimestamp = 0;
  int _shakeCount = 0;

  void startListening({
    required VoidCallback onShake,
    int minimumShakeCount = 1,
    int shakeSlopTimeMS = 600,
    int shakeCountResetTime = 2500,
    double shakeThresholdGravity = 2.2,
  }) {
    if (!_isAvailable) return;
    stopListening();

    _subscription = accelerometerEventStream().listen(
      (event) {
        final gx = event.x / 9.80665;
        final gy = event.y / 9.80665;
        final gz = event.z / 9.80665;
        final gForce = sqrt((gx * gx) + (gy * gy) + (gz * gz));

        if (gForce <= shakeThresholdGravity) return;

        final now = DateTime.now().millisecondsSinceEpoch;
        if (_lastShakeTimestamp + shakeSlopTimeMS > now) return;
        if (_lastShakeTimestamp + shakeCountResetTime < now) {
          _shakeCount = 0;
        }

        _lastShakeTimestamp = now;
        _shakeCount++;
        if (_shakeCount >= minimumShakeCount) {
          onShake();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (error is MissingPluginException || error is PlatformException) {
          debugPrint(
            'SHAKE: sensors plugin not available, disabling shake listener.',
          );
        } else {
          debugPrint('SHAKE: sensor stream error: $error');
        }
        _isAvailable = false;
        stopListening();
      },
      cancelOnError: false,
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
