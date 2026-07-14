# privacy_shield

A Flutter plugin that protects sensitive application content by displaying a privacy overlay when the app is backgrounded, taking screenshots, or during screen recordings.

## Features

- **App Switcher Protection**: Hides sensitive data in the iOS App Switcher and Android Recent Apps list.
- **Multiple Modes**: Supports Solid Color, Black, Blur, or Custom Image overlays.
- **Screenshot Protection**: Block screenshots on Android, and detect them on iOS.
- **Screen Recording Protection**: Protect content during screen recordings on both platforms.

## Platform Support

| Feature | Android | iOS | Notes |
| :--- | :--- | :--- | :--- |
| **Privacy Overlay (Background)** | ✅ Supported | ✅ Supported | Displays the configured privacy mode when the app is backgrounded. |
| **preventScreenshots** | ✅ Supported | ❌ Not Supported | On Android, uses `FLAG_SECURE` to block screenshots. Apple does not allow blocking screenshots on iOS. |
| **onScreenshotTaken (Stream)** | ❌ Not Supported | ✅ Supported | Emits an event when the user takes a screenshot on iOS. |
| **protectDuringScreenRecording**| ✅ Supported | ✅ Supported | On Android, uses `FLAG_SECURE` (blocks the recording completely). On iOS, displays the privacy overlay while recording is active. |

> **Note on iOS Screenshot Protection:** iOS does not allow developers to block users from taking screenshots. Instead, you can use the `PrivacyShield.onScreenshotTaken` stream to listen to screenshot events and react accordingly (e.g., showing a warning or logging the event).

> **Note on Android Screen Recording:** On Android, applying screen recording protection inherently utilizes `FLAG_SECURE`, which blacks out both screenshots and screen recordings completely.

## Usage

```dart
import 'package:privacy_shield/privacy_shield.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with your preferred security settings
  await PrivacyShield.initialize(
    mode: PrivacyMode.blur,
    preventScreenshots: true,
    protectDuringScreenRecording: true,
  );
  
  // (Optional) Listen for screenshots on iOS
  PrivacyShield.onScreenshotTaken.listen((_) {
    print("Screenshot detected!");
  });
  
  runApp(MyApp());
}
```

### Changing Modes at Runtime

```dart
await PrivacyShield.setMode(PrivacyMode.color);
```

### Disabling Temporarily

```dart
await PrivacyShield.disable();
```
