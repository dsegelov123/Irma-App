import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/widgets/theme.dart';

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
    return Scaffold(
      backgroundColor: IrmaColors.brown80,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(IrmaColors.green50),
                backgroundColor: IrmaColors.brown20,
              ),
            ),
            const SizedBox(height: IrmaSpacing.lg),
            Text(
              'IRMA',
              style: IrmaTextStyles.labelXl.copyWith(
                color: Colors.white,
                letterSpacing: 4.0,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
