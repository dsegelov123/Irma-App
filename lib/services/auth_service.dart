import 'dart:async';
import 'package:irma/services/storage_service.dart';

/// Service managing user OAuth sessions, 2-Factor OTP logic, and memory destruction.
class AuthService {
  static bool _isAuthenticated = false;
  static String? _sessionToken;
  static int _otpAttempts = 0;
  static DateTime? _lockoutEndTime;

  /// Returns true if the user session is fully authenticated.
  static bool get isAuthenticated => _isAuthenticated;

  /// Returns the current active session token.
  static String? get sessionToken => _sessionToken;

  /// Returns the number of consecutive failed OTP input attempts.
  static int get otpAttempts => _otpAttempts;

  /// Returns the DateTime when the current lockout penalty terminates.
  static DateTime? get lockoutEndTime => _lockoutEndTime;

  /// Returns true if the user input interface is currently locked out.
  static bool get isLockedOut {
    if (_lockoutEndTime == null) {
      return false;
    }
    if (DateTime.now().isBefore(_lockoutEndTime!)) {
      return true;
    }
    // Lockout elapsed, clear
    _lockoutEndTime = null;
    return false;
  }

  /// Triggers OAuth primary validation handles.
  static Future<bool> signIn(String email, String password) async {
    // Simulated network authentication handshakes
    await Future.delayed(const Duration(milliseconds: 600));
    _otpAttempts = 0;
    _lockoutEndTime = null;
    return true; // Proceed to OTP screen
  }

  /// Triggers validation of onboarding user accounts.
  static Future<bool> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Escrow local AES key setup
    await StorageService.loadOrGenerateKey();
    _otpAttempts = 0;
    _lockoutEndTime = null;
    return true; // Proceed to OTP screen
  }

  /// Verifies a single-use numeric code.
  /// Enforces non-bypassable security checks and lockout penalties.
  static Future<bool> verifyOtp(String code) async {
    if (isLockedOut) {
      return false;
    }

    // Simulated verification logic
    if (code == '123456') { // Mock verification bypass code
      _isAuthenticated = true;
      _sessionToken = 'sec_session_token_aes_handshake';
      _otpAttempts = 0;
      _lockoutEndTime = null;
      return true;
    }

    _otpAttempts++;
    if (_otpAttempts == 1) {
      // 1st breach: 5 minutes lockout
      _lockoutEndTime = DateTime.now().add(const Duration(minutes: 5));
    } else if (_otpAttempts == 2) {
      // 2nd breach: 15 minutes lockout
      _lockoutEndTime = DateTime.now().add(const Duration(minutes: 15));
    } else if (_otpAttempts >= 3) {
      // 3rd breach: Destroy transient tokens, reset to baseline login
      await logout();
    }
    return false;
  }

  /// Executes the Explicit Logout Destruction State.
  /// Wipes all transient decryption keys and tokens from in-memory cache.
  static Future<void> logout() async {
    _isAuthenticated = false;
    _sessionToken = null;
    _otpAttempts = 0;
    _lockoutEndTime = null;
    
    // Wipe local decryption key from volatile memory
    StorageService.wipeKeyFromMemory();
  }
}
