// Auth Provider

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum AuthMethod {
  email,
  google,
  microsoft,
  guest,
}

class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final AuthMethod authMethod;
  final bool isGuest;

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.authMethod,
    this.isGuest = false,
  });

  factory User.guest() => User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        displayName: 'Guest User',
        authMethod: AuthMethod.guest,
        isGuest: true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'authMethod': authMethod.name,
        'isGuest': isGuest,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String?,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        authMethod: AuthMethod.values.firstWhere(
          (e) => e.name == json['authMethod'],
          orElse: () => AuthMethod.guest,
        ),
        isGuest: json['isGuest'] as bool? ?? false,
      );
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isFirebaseAvailable = false;

  AuthProvider();

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _user?.isGuest ?? false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  /// Initialize auth state - check for existing session
  Future<void> initialize() async {
    try {
      // Firebase disabled for Windows - offline mode only
      _isFirebaseAvailable = false;
      debugPrint('Running in offline mode (Firebase disabled)');

      // Check for saved user session
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('saved_user');
      final guestId = prefs.getString('guest_user_id');

      if (savedUserJson != null) {
        try {
          final userMap = _parseUserJson(savedUserJson);
          _user = User.fromJson(userMap);
          _status = AuthStatus.authenticated;
        } catch (e) {
          debugPrint('Failed to restore user: $e');
          _status = AuthStatus.unauthenticated;
        }
      } else if (guestId != null) {
        _user = User(
          id: guestId,
          displayName: 'Guest User',
          authMethod: AuthMethod.guest,
          isGuest: true,
        );
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Map<String, dynamic> _parseUserJson(String jsonString) {
    // Simple JSON parsing
    return {
      'id': _extractValue(jsonString, 'id') ?? '',
      'email': _extractValue(jsonString, 'email'),
      'displayName': _extractValue(jsonString, 'displayName'),
      'photoUrl': _extractValue(jsonString, 'photoUrl'),
      'authMethod': _extractValue(jsonString, 'authMethod') ?? 'guest',
      'isGuest': _extractValue(jsonString, 'isGuest') == 'true',
    };
  }

  String? _extractValue(String json, String key) {
    final pattern = RegExp('"$key"\\s*:\\s*"?([^",}]+)"?');
    final match = pattern.firstMatch(json);
    if (match != null) {
      final value = match.group(1);
      return value == 'null' || value == '' ? null : value;
    }
    return null;
  }

  // Email/Password Sign In (offline mode)
  Future<bool> signInWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Offline mode - simple validation
      if (email.isNotEmpty && password.length >= 6) {
        _user = User(
          id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          displayName: email.split('@').first,
          authMethod: AuthMethod.email,
        );
        await _saveUser(_user!);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Please enter a valid email and password (min 6 chars)';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Sign in failed: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Create Account (offline mode)
  Future<bool> createAccount(String email, String password, String name) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
        _user = User(
          id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          displayName: name,
          authMethod: AuthMethod.email,
        );
        await _saveUser(_user!);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Please fill in all fields (password min 6 chars)';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Account creation failed: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Sign Up with Email - alias for createAccount
  Future<bool> signUpWithEmail(
      String email, String password, String? displayName) async {
    return createAccount(
        email, password, displayName ?? email.split('@').first);
  }

  // Google Sign In - Not available in offline mode
  Future<bool> signInWithGoogle() async {
    _errorMessage = 'Google Sign-In not available in offline mode';
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  // Microsoft Sign In - Not available in offline mode
  Future<bool> signInWithMicrosoft() async {
    _errorMessage = 'Microsoft Sign-In not available in offline mode';
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  // Continue as Guest
  Future<bool> continueAsGuest() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      _user = User.guest();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('guest_user_id', _user!.id);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to continue as guest: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Send Password Reset Email - Not available in offline mode
  Future<bool> sendPasswordResetEmail(String email) async {
    _errorMessage = 'Password reset not available in offline mode';
    return false;
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('guest_user_id');
      await prefs.remove('saved_user');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Save user to preferences
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final json =
        '{"id":"${user.id}","email":"${user.email ?? ""}","displayName":"${user.displayName ?? ""}","photoUrl":"${user.photoUrl ?? ""}","authMethod":"${user.authMethod.name}","isGuest":${user.isGuest}}';
    await prefs.setString('saved_user', json);
  }
}
