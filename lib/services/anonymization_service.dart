import 'dart:convert';
import 'package:crypto/crypto.dart';

class AnonymizationService {
  // Generate anonymous ID from Firebase UID
  String generateAnonymousId(String firebaseUid) {
    final bytes = utf8.encode(firebaseUid);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Anonymize email address
  String anonymizeEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    final visiblePart = username.length >= 2 ? username.substring(0, 2) : username;
    final hiddenPart = '*' * (username.length - 2).clamp(3, 10);

    return '$visiblePart$hiddenPart@$domain';
  }

  // Encrypt sensitive data
  String encryptData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
