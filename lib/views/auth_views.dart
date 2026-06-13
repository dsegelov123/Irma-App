import 'dart:async';
import 'package:flutter/material.dart';
import 'package:irma/services/auth_service.dart';

/// -------------------------------------------------------------
/// SIGN-UP VIEW
/// -------------------------------------------------------------
class SignUpView extends StatefulWidget {
  final Function(String route) onNavigation;
  const SignUpView({super.key, required this.onNavigation});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final success = await AuthService.signUp(
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    if (success) {
      widget.onNavigation('otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F160F), // Mindful Brown 100
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join Irma to secure your tracking baseline.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF697077), // Optimistic Gray 60
                  ),
                ),
                const SizedBox(height: 48),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email Address'),
                  validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 24),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Password'),
                  validator: (val) => val == null || val.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: _buttonStyle(),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Profile'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => widget.onNavigation('signIn'),
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: Color(0xFF4B3425),
                        fontWeight: FontWeight.w700,
                      ),
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

/// -------------------------------------------------------------
/// SIGN-IN VIEW
/// -------------------------------------------------------------
class SignInView extends StatefulWidget {
  final Function(String route) onNavigation;
  const SignInView({super.key, required this.onNavigation});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final success = await AuthService.signIn(
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    if (success) {
      widget.onNavigation('otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F160F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access your secure, E2EE wellness data.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF697077),
                  ),
                ),
                const SizedBox(height: 48),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email Address'),
                  validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 24),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Password'),
                  validator: (val) => val == null || val.isEmpty ? 'Password required' : null,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: _buttonStyle(),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => widget.onNavigation('signUp'),
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: Color(0xFF4B3425),
                        fontWeight: FontWeight.w700,
                      ),
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

/// -------------------------------------------------------------
/// 2-FACTOR OTP VERIFICATION VIEW
/// -------------------------------------------------------------
class OtpVerificationView extends StatefulWidget {
  final Function(String route) onNavigation;
  const OtpVerificationView({super.key, required this.onNavigation});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  int _resendSecondsRemaining = 60;
  Timer? _resendTimer;
  Timer? _lockoutTimer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startLockoutChecker();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendSecondsRemaining = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsRemaining > 0) {
        setState(() => _resendSecondsRemaining--);
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  void _startLockoutChecker() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (AuthService.isLockedOut) {
        setState(() {
          _errorMessage = _lockoutMessage();
        });
      } else {
        setState(() {
          if (_errorMessage != null && _errorMessage!.contains('locked')) {
            _errorMessage = null;
          }
        });
      }
    });
  }

  String _lockoutMessage() {
    final diff = AuthService.lockoutEndTime?.difference(DateTime.now());
    if (diff == null || diff.isNegative) return 'Too many attempts. Locked out.';
    final mins = diff.inMinutes;
    final secs = diff.inSeconds % 60;
    return 'Too many failed attempts. Locked out for ${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.';
  }

  Future<void> _submit() async {
    if (AuthService.isLockedOut) return;
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.verifyOtp(_codeController.text);
    
    setState(() => _isLoading = false);
    
    if (success) {
      widget.onNavigation('onboardingRegularity');
    } else {
      setState(() {
        if (AuthService.isLockedOut) {
          _errorMessage = _lockoutMessage();
        } else if (AuthService.otpAttempts >= 3) {
          // tertiary breach leads to logout
          _errorMessage = 'Session reset due to security policy.';
          Future.delayed(const Duration(seconds: 2), () {
            widget.onNavigation('signIn');
          });
        } else {
          _errorMessage = 'Incorrect code. Attempts remaining before lockout: ${3 - AuthService.otpAttempts}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = AuthService.isLockedOut;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F160F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We have dispatched a 6-digit passcode. Please input it below to unlock access.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF697077),
                  ),
                ),
                const SizedBox(height: 48),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD2C2), // Empathy Orange 20
                      borderRadius: BorderRadius.circular(1000), // Pill Shape
                    ),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDF4B01), // Orange 60
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // OTP Text Field
                TextFormField(
                  controller: _codeController,
                  enabled: !locked,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8.0,
                  ),
                  decoration: _inputDecoration('Verification Code (123456)'),
                  validator: (val) => val == null || val.length != 6 ? 'Enter 6-digit code' : null,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (locked || _isLoading) ? null : _submit,
                    style: _buttonStyle(),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify Code'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: _resendSecondsRemaining > 0
                    ? Text(
                        'Resend code in $_resendSecondsRemaining seconds',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          color: Color(0xFF697077),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : TextButton(
                        onPressed: locked ? null : _startResendTimer,
                        child: const Text(
                          'Resend Verification Code',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            color: Color(0xFF4B3425),
                            fontWeight: FontWeight.w700,
                          ),
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

/// -------------------------------------------------------------
/// DECORATION HELPERS
/// -------------------------------------------------------------
InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.w500,
      color: Color(0xFF697077),
    ),
    contentPadding: const EdgeInsets.all(24),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: Color(0xFF9BB068), width: 1), // Sage Green 1px
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: Color(0xFF9BB068), width: 2), // Sage Green 2px
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: Color(0xFFC1C6CD), width: 1), // Disabled Gray
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: Color(0xFFFE814B), width: 1), // Orange 40 Error
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: Color(0xFFFE814B), width: 2),
    ),
  );
}

ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: const Color(0xFF4B3425), // Warm Earthy Brown
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(1000), // Pill Shape
    ),
    textStyle: const TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}
