import 'package:flutter/material.dart';
import 'package:irma/views/loading_view.dart';
import 'package:irma/views/auth_views.dart';
import 'package:irma/views/onboarding_view.dart';
import 'package:irma/views/main_shell.dart';
import 'package:irma/widgets/lock_gate.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the Irma application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Urbanist',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainRouter(),
    );
  }
}

/// Dynamic routing manager switching layouts based on session and setup progress.
class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  State<MainRouter> createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  String _currentRoute = 'loading';

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;
    switch (_currentRoute) {
      case 'loading':
        currentWidget = LoadingView(onNavigation: _navigateTo);
        break;
      case 'signIn':
        currentWidget = SignInView(onNavigation: _navigateTo);
        break;
      case 'signUp':
        currentWidget = SignUpView(onNavigation: _navigateTo);
        break;
      case 'otp':
        currentWidget = OtpVerificationView(onNavigation: _navigateTo);
        break;
      case 'onboardingRegularity':
        currentWidget = OnboardingWizardView(onNavigation: _navigateTo);
        break;
      case 'mainShell':
        // Enforce native biometrics lock gate wrapper on primary application interface
        currentWidget = LockGate(
          child: MainShell(onNavigation: _navigateTo),
        );
        break;
      default:
        currentWidget = LoadingView(onNavigation: _navigateTo);
    }

    return currentWidget;
  }
}
