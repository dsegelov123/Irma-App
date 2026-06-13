import 'dart:async';
import 'package:flutter/material.dart';
import 'package:irma/services/auth_service.dart';
import 'package:irma/widgets/theme.dart';

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
          padding: const EdgeInsets.all(IrmaSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: IrmaSpacing.xxl),
                Text(
                  'Create Account',
                  style: IrmaTextStyles.label2xl.copyWith(fontSize: 32, color: IrmaColors.brown100),
                ),
                const SizedBox(height: IrmaSpacing.xs),
                Text(
                  'Join Irma to secure your tracking baseline.',
                  style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.gray60),
                ),
                const SizedBox(height: IrmaSpacing.xxl),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: IrmaInputDecoration.standard(labelText: 'Email Address'),
                  validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: IrmaSpacing.lg),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: IrmaInputDecoration.standard(labelText: 'Password'),
                  validator: (val) => val == null || val.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: IrmaSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: IrmaButtonStyles.primaryLg(),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Profile'),
                  ),
                ),
                const SizedBox(height: IrmaSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: () => widget.onNavigation('signIn'),
                    child: Text(
                      'Already have an account? Sign In',
                      style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
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
          padding: const EdgeInsets.all(IrmaSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: IrmaSpacing.xxl),
                Text(
                  'Welcome Back',
                  style: IrmaTextStyles.label2xl.copyWith(fontSize: 32, color: IrmaColors.brown100),
                ),
                const SizedBox(height: IrmaSpacing.xs),
                Text(
                  'Access your secure, E2EE wellness data.',
                  style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.gray60),
                ),
                const SizedBox(height: IrmaSpacing.xxl),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: IrmaInputDecoration.standard(labelText: 'Email Address'),
                  validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: IrmaSpacing.lg),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: IrmaInputDecoration.standard(labelText: 'Password'),
                  validator: (val) => val == null || val.isEmpty ? 'Password required' : null,
                ),
                const SizedBox(height: IrmaSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: IrmaButtonStyles.primaryLg(),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: IrmaSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: () => widget.onNavigation('signUp'),
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
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
          padding: const EdgeInsets.all(IrmaSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: IrmaSpacing.xxl),
                Text(
                  'Verification Code',
                  style: IrmaTextStyles.label2xl.copyWith(fontSize: 32, color: IrmaColors.brown100),
                ),
                const SizedBox(height: IrmaSpacing.xs),
                Text(
                  'We have dispatched a 6-digit passcode. Please input it below to unlock access.',
                  style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.gray60),
                ),
                const SizedBox(height: IrmaSpacing.xxl),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.sm),
                    decoration: IrmaCards.error(),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.orange60),
                    ),
                  ),
                  const SizedBox(height: IrmaSpacing.lg),
                ],
                // OTP Text Field
                TextFormField(
                  controller: _codeController,
                  enabled: !locked,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: IrmaTextStyles.label2xl.copyWith(
                    fontSize: 24,
                    letterSpacing: 8.0,
                  ),
                  decoration: IrmaInputDecoration.standard(labelText: 'Verification Code (123456)'),
                  validator: (val) => val == null || val.length != 6 ? 'Enter 6-digit code' : null,
                ),
                const SizedBox(height: IrmaSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (locked || _isLoading) ? null : _submit,
                    style: IrmaButtonStyles.primaryLg(),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify Code'),
                  ),
                ),
                const SizedBox(height: IrmaSpacing.lg),
                Center(
                  child: _resendSecondsRemaining > 0
                    ? Text(
                        'Resend code in $_resendSecondsRemaining seconds',
                        style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.gray60),
                      )
                    : TextButton(
                        onPressed: locked ? null : _startResendTimer,
                        child: Text(
                          'Resend Verification Code',
                          style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
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
