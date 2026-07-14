import 'package:flutter/material.dart';
import 'privacy_mode.dart';

class PrivacyShieldOptions {
  final bool enabled;
  final PrivacyMode mode;
  final double blurStrength;
  final Color color;
  final String? image;
  final bool preventScreenshots;
  final bool protectDuringScreenRecording;
  final Duration animationDuration;

  const PrivacyShieldOptions({
    this.enabled = true,
    this.mode = PrivacyMode.black,
    this.blurStrength = 20.0,
    this.color = Colors.black,
    this.image,
    this.preventScreenshots = false,
    this.protectDuringScreenRecording = false,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'mode': mode.name,
      'blurStrength': blurStrength,
      'color': color.value,
      'image': image,
      'preventScreenshots': preventScreenshots,
      'protectDuringScreenRecording': protectDuringScreenRecording,
      'animationDuration': animationDuration.inMilliseconds,
    };
  }
}
