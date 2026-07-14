import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'privacy_shield_platform_interface.dart';

/// An implementation of [PrivacyShieldPlatform] that uses method channels.
class MethodChannelPrivacyShield extends PrivacyShieldPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('privacy_shield');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
