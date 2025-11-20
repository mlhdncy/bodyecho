import 'package:flutter/foundation.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      if (_authService.isAuthenticated) {
        _currentUser = await _authService.getCurrentUserData(
          _authService.currentUserId!,
        );
        notifyListeners();
      }
    } catch (e) {
      // Firebase not initialized yet - this is OK for now
      debugPrint('Auth check skipped: Firebase not initialized');
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> reloadUser() async {
    if (_currentUser != null) {
      try {
        _currentUser = await _authService.getCurrentUserData(_currentUser!.anonymousId);
        notifyListeners();
      } catch (e) {
        debugPrint('Error reloading user: $e');
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
