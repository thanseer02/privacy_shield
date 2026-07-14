import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget that automatically blurs the entire UI whenever the app
/// goes into the background (paused/inactive), and restores visibility
/// when the app returns to the foreground (resumed).
///
/// This provides a beautiful visual transition and ensures that on iOS,
/// the OS snapshot captures the blurred Flutter UI. On Android, it works
/// alongside the native FLAG_SECURE implementation.
///
/// Usage:
/// ```dart
/// runApp(
///   PrivacyShieldWidget(
///     child: MyApp(),
///   ),
/// );
/// ```
class PrivacyShieldWidget extends StatefulWidget {
  /// The widget tree that should be visible normally.
  final Widget child;

  /// Intensity of the Gaussian blur applied when backgrounded.
  final double blurSigma;

  /// Darkness overlay color.
  final Color overlayColor;

  /// Duration of the fade animation.
  final Duration fadeDuration;

  const PrivacyShieldWidget({
    super.key,
    required this.child,
    this.blurSigma = 25.0,
    this.overlayColor = const Color(0x33000000), // 20% opacity black
    this.fadeDuration = const Duration(milliseconds: 180),
  });

  @override
  State<PrivacyShieldWidget> createState() => _PrivacyShieldWidgetState();
}

class _PrivacyShieldWidgetState extends State<PrivacyShieldWidget>
    with WidgetsBindingObserver {
  bool _blurEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_blurEnabled) {
        setState(() => _blurEnabled = true);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_blurEnabled) {
        setState(() => _blurEnabled = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_blurEnabled)
            AnimatedOpacity(
              opacity: _blurEnabled ? 1 : 0,
              duration: widget.fadeDuration,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blurSigma,
                      sigmaY: widget.blurSigma,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                  Container(color: widget.overlayColor),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
