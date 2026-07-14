import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'privacy_shield_method_channel.dart';

abstract class PrivacyShieldPlatform extends PlatformInterface {
  /// Constructs a PrivacyShieldPlatform.
  PrivacyShieldPlatform() : super(token: _token);

  static final Object _token = Object();

  static PrivacyShieldPlatform _instance = MethodChannelPrivacyShield();

  /// The default instance of [PrivacyShieldPlatform] to use.
  ///
  /// Defaults to [MethodChannelPrivacyShield].
  static PrivacyShieldPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PrivacyShieldPlatform] when
  /// they register themselves.
  static set instance(PrivacyShieldPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
