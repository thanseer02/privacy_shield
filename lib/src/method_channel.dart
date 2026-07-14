import 'package:flutter/services.dart';
import 'models.dart';
import 'privacy_mode.dart';

class PrivacyShieldMethodChannel {
  static const MethodChannel _channel = MethodChannel('privacy_shield');

  static Future<void> initialize(PrivacyShieldOptions options) async {
    await _channel.invokeMethod('initialize', options.toMap());
  }

  static Future<void> enable() async {
    await _channel.invokeMethod('enable');
  }

  static Future<void> disable() async {
    await _channel.invokeMethod('disable');
  }

  static Future<void> setMode(PrivacyMode mode) async {
    await _channel.invokeMethod('setMode', {'mode': mode.name});
  }

  static Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
  }
}
