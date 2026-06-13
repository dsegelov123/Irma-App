import 'package:flutter/material.dart';
import 'package:irma/services/biometric_service.dart';

/// A secure access gate wrapping the root viewport.
/// Covers application states during background transitions and enforces biometrics.
class LockGate extends StatefulWidget {
  final Widget child;
  const LockGate({super.key, required this.child});

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  bool _isLocked = true;
  DateTime? _backgroundedTime;
  
  // Inactivity timeout threshold (5 minutes / 300 seconds)
  static const int _timeoutSeconds = 300;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedTime = DateTime.now();
      setState(() {
        _isLocked = true; // Immediately mask screen for multitasking manager privacy
      });
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundedTime != null) {
        final elapsed = DateTime.now().difference(_backgroundedTime!).inSeconds;
        if (elapsed < _timeoutSeconds) {
          // Return is within timeout window, auto-unlock
          setState(() {
            _isLocked = false;
          });
        } else {
          // Inactivity threshold exceeded, prompt authentication
          _authenticate();
        }
      } else {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    final success = await BiometricService.authenticate();
    if (success) {
      setState(() {
        _isLocked = false;
      });
    } else {
      setState(() {
        _isLocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF4B3425), // Mindful Brown 80 (Primary Brand)
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branded Security Indicator (Sage Green/White)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9BB068), // Serenity Green / Sage Green
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5EAD7), width: 4),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Irma is locked',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please authenticate using biometrics to unlock and resume your session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE8DDD9), // Mindful Brown 20 / Light Tan
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('Unlock with Biometrics'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF4B3425),
                    backgroundColor: const Color(0xFFE8DDD9),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000), // Pill Shape
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
