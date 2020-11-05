
import 'dart:async';

import 'package:flutter/services.dart';

/*
  see: https://flutter.dev/docs/development/platform-integration/c-interop
 */
class NativeSqlcipher {
  static const MethodChannel _channel =
      const MethodChannel('native_sqlcipher');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
