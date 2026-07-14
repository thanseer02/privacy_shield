library privacy_shield;

import 'package:flutter/material.dart';

import 'src/event_channel.dart';
import 'src/method_channel.dart';
import 'src/models.dart';
import 'src/privacy_mode.dart';

export 'src/models.dart';
export 'src/privacy_mode.dart';

/// The main class for controlling the privacy shield.
class PrivacyShield {
  /// Stream that emits an event whenever the user takes a screenshot.
  /// Note: This is currently only supported on iOS.
  static Stream<void> get onScreenshotTaken => PrivacyShieldEventChannel.onScreenshotTaken;

  /// Initializes the privacy shield with the given [mode] and options.
  static Future<void> initialize({
    bool enabled = true,
    PrivacyMode mode = PrivacyMode.black,
    double blurStrength = 20.0,
    Color color = Colors.black,
    String? image,
    bool preventScreenshots = false,
    bool protectDuringScreenRecording = false,
    Duration animationDuration = const Duration(milliseconds: 200),
  }) async {
    final options = PrivacyShieldOptions(
      enabled: enabled,
      mode: mode,
      blurStrength: blurStrength,
      color: color,
      image: image,
      preventScreenshots: preventScreenshots,
      protectDuringScreenRecording: protectDuringScreenRecording,
      animationDuration: animationDuration,
    );
    await PrivacyShieldMethodChannel.initialize(options);
  }

  /// Enables the privacy shield. It will show the overlay when the app goes to the background.
  static Future<void> enable() async {
    await PrivacyShieldMethodChannel.enable();
  }

  /// Disables the privacy shield. It will no longer show the overlay when the app goes to the background.
  static Future<void> disable() async {
    await PrivacyShieldMethodChannel.disable();
  }

  /// Changes the [PrivacyMode] of the privacy shield.
  static Future<void> setMode(PrivacyMode mode) async {
    await PrivacyShieldMethodChannel.setMode(mode);
  }

  /// Disposes the privacy shield and removes any background listeners.
  static Future<void> dispose() async {
    await PrivacyShieldMethodChannel.dispose();
  }
}
