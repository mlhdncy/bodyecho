import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../config/app_colors.dart';

/// Dialog shown when a user unlocks a new badge
class BadgeUnlockDialog extends StatelessWidget {
  final BadgeDefinition badge;

  const BadgeUnlockDialog({
    super.key,
    required this.badge,
  });

  /// Show the badge unlock dialog
  static Future<void> show(BuildContext context, BadgeDefinition badge) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BadgeUnlockDialog(badge: badge),
    );
  }

  Color _getTierColor(int tier) {
    switch (tier) {
      case 1:
        return const Color(0xFFCD7F32); // Bronze
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFFFD700); // Gold
      case 4:
        return AppColors.primaryTeal; // Platinum
      default:
        return AppColors.primaryTeal;
    }
  }

  String _getTierName(int tier) {
    switch (tier) {
      case 1:
        return 'Bronz';
      case 2:
        return 'Gümüş';
      case 3:
        return 'Altın';
      case 4:
        return 'Platin';
      default:
        return 'Rozet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(badge.tier);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: tierColor.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: AppColors.success,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Yeni Rozet Kazandın!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Badge icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: tierColor.withAlpha(40),
                shape: BoxShape.circle,
                border: Border.all(
                  color: tierColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: tierColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tierColor,
                  width: 2,
                ),
              ),
              child: Text(
                _getTierName(badge.tier),
                style: TextStyle(
                  color: tierColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Badge title
            Text(
              badge.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Badge description
            Text(
              badge.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tierColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Harika!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
