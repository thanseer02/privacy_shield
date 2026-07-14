# Privacy Shield

A comprehensive Flutter plugin to protect your app's content from being exposed in the App Switcher (recent apps view) and to prevent screenshots/screen recording.

`privacy_shield` provides both native (MethodChannels) and Flutter-level implementations to secure your application's sensitive data when it goes to the background or when a user attempts to capture the screen.

## Features

- **App Switcher Protection**: Hide or blur your app's screen when it goes to the background (app switcher/recent apps list).
- **Screenshot Prevention**: Prevent users from taking screenshots of your app (Android: `FLAG_SECURE`, iOS: screen shield).
- **Multiple Privacy Modes**: Choose from Black, Blur, Color, or custom Image overlay.
- **Flutter Widget**: A `PrivacyShieldWidget` that automatically blurs the UI when inactive/paused for seamless transitions.
- **Dynamic Updates**: Change the privacy mode or toggle screenshot prevention dynamically at runtime.

## Installation

Add `privacy_shield` to your `pubspec.yaml`:

```yaml
dependencies:
  privacy_shield: ^0.0.1
```

## Initialization & Working

You can protect your app in two main ways: using the native `PrivacyShield` initialization or wrapping your app in `PrivacyShieldWidget`. For best results, use both together!

### 1. Native Initialization (Method Channel)

Initialize `PrivacyShield` in your `main()` function before calling `runApp()`. This sets up the native protections (like Android's `FLAG_SECURE` and iOS's background shield).

```dart
import 'package:flutter/material.dart';
import 'package:privacy_shield/privacy_shield.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await PrivacyShield.initialize(
    mode: PrivacyMode.black,       // The mode to use when app is in background
    preventScreenshots: true,      // Prevent screenshots and screen recording
  );
  
  runApp(const MyApp());
}
```

#### Available Options for `PrivacyShield.initialize()`:
- `mode` (`PrivacyMode`): The visual mode when backgrounded (`black`, `blur`, `color`, `image`).
- `preventScreenshots` (`bool`): Blocks screenshots and screen recordings.
- `color` (`Color`): The overlay color used if `PrivacyMode.color` is selected.
- `blurStrength` (`double`): The intensity of the blur.

### 2. Flutter UI Widget

For a smooth UI transition when the app goes inactive (before the OS fully backgrounds it), wrap your main app widget with `PrivacyShieldWidget`.

```dart
import 'package:flutter/material.dart';
import 'package:privacy_shield/privacy_shield.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PrivacyShieldWidget(
      blurSigma: 25.0, // Adjust the blur intensity
      overlayColor: const Color(0x33000000), // Optional darkness overlay
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Secure App')),
          body: const Center(child: Text('Sensitive Data')),
        ),
      ),
    );
  }
}
```

### Dynamic Updates at Runtime

You can update the privacy settings dynamically while the app is running. For instance, you might want to disable screenshot prevention when the user is not viewing sensitive information.

```dart
// Change the background privacy mode dynamically
await PrivacyShield.setMode(PrivacyMode.blur);

// Toggle screenshot prevention dynamically
// Call initialize again to update the configuration
await PrivacyShield.initialize(
  mode: PrivacyMode.blur,
  preventScreenshots: false, // Turn off screenshot prevention
);
```

### Modes Available (`PrivacyMode`)

- `PrivacyMode.black`: Covers the screen with a solid black view.
- `PrivacyMode.blur`: Applies a blur effect to the screen.
- `PrivacyMode.color`: Covers the screen with a specified color.
- `PrivacyMode.image`: Covers the screen with a custom image.

## Platform Support

- **Android**: Supports `FLAG_SECURE` for screenshot prevention and native activity lifecycle for background overlays.
- **iOS**: Supports native blurred/color views over the application window during backgrounding and screenshot prevention hooks.
