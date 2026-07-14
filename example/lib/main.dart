import 'package:flutter/material.dart';
import 'dart:async';
import 'package:privacy_shield/privacy_shield.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await PrivacyShield.initialize(
    mode: PrivacyMode.black,
    preventScreenshots: false,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PrivacyMode _currentMode = PrivacyMode.black;
  bool _isSecure = false;

  Future<void> _setMode(PrivacyMode mode) async {
    await PrivacyShield.setMode(mode);
    setState(() {
      _currentMode = mode;
    });
  }
  
  Future<void> _toggleSecure() async {
    final newSecure = !_isSecure;
    // Re-initialize to update the screenshot policy (Android only)
    await PrivacyShield.initialize(
      mode: _currentMode,
      preventScreenshots: newSecure,
    );
    setState(() {
      _isSecure = newSecure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Shield Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Mode: ${_currentMode.name}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _setMode(PrivacyMode.black),
                child: const Text('Set Black Mode'),
              ),
              ElevatedButton(
                onPressed: () => _setMode(PrivacyMode.blur),
                child: const Text('Set Blur Mode'),
              ),
              ElevatedButton(
                onPressed: () => _setMode(PrivacyMode.color),
                child: const Text('Set Color Mode'),
              ),
              const SizedBox(height: 40),
              Text(
                'Prevent Screenshots: $_isSecure',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _toggleSecure,
                child: const Text('Toggle Screenshot Policy'),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Put the app in the background to see the privacy shield in action in the App Switcher!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
