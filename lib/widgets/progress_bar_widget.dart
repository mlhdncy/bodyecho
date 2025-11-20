import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ProgressBarWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color color;
  final Color backgroundColor;

  const ProgressBarWidget({
    super.key,
    required this.progress,
    this.height = 10,
    this.color = AppColors.primaryTeal,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedProgress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

class ProgressBarWithLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final int currentValue;
  final int maxValue;
  final Color color;
  final String? unit;

  const ProgressBarWithLabel({
    super.key,
    required this.icon,
    required this.title,
    required this.currentValue,
    required this.maxValue,
    required this.color,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentValue / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: currentValue.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: ' / $maxValue',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProgressBarWidget(
          progress: progress,
          height: 8,
          color: color,
        ),
      ],
    );
  }
}

class ProgressBarWithPercentage extends StatelessWidget {
  final IconData icon;
  final String title;
  final int percentage; // 0-100
  final Color color;

  const ProgressBarWithPercentage({
    super.key,
    required this.icon,
    required this.title,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = percentage / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProgressBarWidget(
          progress: progress,
          height: 8,
          color: color,
        ),
      ],
    );
  }
}
