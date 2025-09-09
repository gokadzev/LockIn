import 'dart:async';

import 'package:flutter/services.dart';

class TimezoneHelper {
  static const MethodChannel _channel = MethodChannel('lockin/native_timezone');

  /// Returns the platform's canonical IANA timezone id, or throws.
  static Future<String> getLocalTimezone() async {
    final dynamic result = await _channel.invokeMethod('getLocalTimezone');
    if (result is String) return result;
    throw Exception('Invalid timezone from platform: $result');
  }
}
