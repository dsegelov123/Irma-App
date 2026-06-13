import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';

/// Boot-level isolation view running startup routines and encryption checks.
class LoadingView extends StatefulWidget {
  final Function(String route) onNavigation;
  const LoadingView({super.key, required this.onNavigation});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // 1. Initialize local DB sandbox (Hive and encryption key)
      await StorageService.init();
      
      // 2. Run simulated hardware wake checks
      await Future.delayed(const Duration(seconds: 1));

      // 3. Evaluate active user session status
      final completed = StorageService.settingsBox.get('onboarding_completed', defaultValue: false);
      
      if (completed) {
        widget.onNavigation('mainShell');
      } else {
        widget.onNavigation('signUp');
      }
    } catch (_) {
      // If error occurs (e.g. key initialization failure), default back to signUp
      widget.onNavigation('signUp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4B3425), // Mindful Brown 80 (Primary Brand)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9BB068)), // Sage Green
                backgroundColor: Color(0xFFE8DDD9), // Light Tan
              ),
            ),
            SizedBox(height: 24),
            Text(
              'IRMA',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
