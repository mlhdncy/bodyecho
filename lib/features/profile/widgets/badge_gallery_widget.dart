import 'package:flutter/material.dart';
import '../../../models/badge_model.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/badge_unlock_dialog.dart';

/// Widget to display user's badge collection
class BadgeGalleryWidget extends StatelessWidget {
  final List<String> earnedBadgeIds;
  final List<BadgeDefinition> allBadges;

  const BadgeGalleryWidget({
    super.key,
    required this.earnedBadgeIds,
    required this.allBadges,
  });

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

  void _showBadgeDetails(BuildContext context, BadgeDefinition badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => BadgeUnlockDialog(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rozetler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${earnedBadgeIds.length}/${allBadges.length}',
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: allBadges.isEmpty
                  ? 0
                  : earnedBadgeIds.length / allBadges.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // Badge grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: allBadges.length,
            itemBuilder: (context, index) {
              final badge = allBadges[index];
              final isEarned = earnedBadgeIds.contains(badge.id);

              return GestureDetector(
                onTap: () => _showBadgeDetails(context, badge, isEarned),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isEarned
                            ? _getTierColor(badge.tier).withAlpha(60)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isEarned
                              ? _getTierColor(badge.tier)
                              : Colors.grey.shade300,
                          width: 3,
                        ),
                        boxShadow: isEarned
                            ? [
                                BoxShadow(
                                  color: _getTierColor(badge.tier).withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          badge.icon,
                          style: TextStyle(
                            fontSize: 28,
                            color: isEarned ? null : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Badge title
                    Text(
                      badge.title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isEarned
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Lock icon for locked badges
                    if (!isEarned)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.lock_outline,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
