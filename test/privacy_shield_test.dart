import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_shield/privacy_shield.dart';
import 'package:privacy_shield/privacy_shield_platform_interface.dart';
import 'package:privacy_shield/privacy_shield_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPrivacyShieldPlatform
    with MockPlatformInterfaceMixin
    implements PrivacyShieldPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PrivacyShieldPlatform initialPlatform = PrivacyShieldPlatform.instance;

  test('$MethodChannelPrivacyShield is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPrivacyShield>());
  });

  test('getPlatformVersion', () async {
    PrivacyShield privacyShieldPlugin = PrivacyShield();
    MockPrivacyShieldPlatform fakePlatform = MockPrivacyShieldPlatform();
    PrivacyShieldPlatform.instance = fakePlatform;

    expect(await privacyShieldPlugin.getPlatformVersion(), '42');
  });
}
