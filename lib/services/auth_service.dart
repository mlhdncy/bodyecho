import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/daily_metric_model.dart';
import 'anonymization_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnonymizationService _anonymizer = AnonymizationService();

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUid = userCredential.user!.uid;
      final anonymousId = _anonymizer.generateAnonymousId(firebaseUid);

      final user = UserModel(
        id: firebaseUid,
        anonymousId: anonymousId,
        fullName: fullName,
        email: _anonymizer.anonymizeEmail(email),
        avatarType: 'bunny_pink',
      );

      await _firestore.collection('users').doc(firebaseUid).set(user.toMap());

      // Create initial daily metric
      final dailyMetric = DailyMetricModel(userId: anonymousId);
      await _firestore.collection('dailyMetrics').add(dailyMetric.toMap());

      return user;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign In
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUid = userCredential.user!.uid;
      return await getCurrentUserData(firebaseUid);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Current User Data
  Future<UserModel> getCurrentUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Kullanıcı bulunamadı');
    }
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'user-not-found':
          return 'Kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Hatalı şifre.';
        default:
          return 'Bir hata oluştu: ${e.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu.';
  }
}
