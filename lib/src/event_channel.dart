import 'package:flutter/services.dart';

class PrivacyShieldEventChannel {
  static const EventChannel _eventChannel = EventChannel('privacy_shield/events');
  static Stream<void>? _onScreenshotTaken;

  static Stream<void> get onScreenshotTaken {
    _onScreenshotTaken ??= _eventChannel.receiveBroadcastStream().map((event) => null);
    return _onScreenshotTaken!;
  }
}
