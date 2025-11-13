import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum AvatarMood {
  happy,      // Tüm hedefler tamamlanmış
  excited,    // Hedeflerin üzerinde
  normal,     // Ortalama ilerleme
  tired,      // Az aktivite
  thirsty,    // Su eksik
  sad,        // Hedeflere uzak
  worried,    // Çok düşük aktivite
}

class HealthAvatarWidget extends StatelessWidget {
  final AvatarMood mood;
  final double size;

  const HealthAvatarWidget({
    super.key,
    required this.mood,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getBackgroundColor().withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Face
          CustomPaint(
            size: Size(size * 0.8, size * 0.8),
            painter: AvatarFacePainter(mood: mood),
          ),

          // Optional accessories based on mood
          if (mood == AvatarMood.thirsty)
            Positioned(
              top: size * 0.2,
              right: size * 0.15,
              child: Icon(
                Icons.water_drop,
                color: AppColors.accentBlue.withValues(alpha: 0.7),
                size: size * 0.15,
              ),
            ),

          if (mood == AvatarMood.excited)
            Positioned(
              top: size * 0.15,
              right: size * 0.2,
              child: Icon(
                Icons.star,
                color: Colors.amber,
                size: size * 0.15,
              ),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (mood) {
      case AvatarMood.happy:
      case AvatarMood.excited:
        return AppColors.accentGreen.withValues(alpha: 0.2);
      case AvatarMood.normal:
        return AppColors.primaryTeal.withValues(alpha: 0.2);
      case AvatarMood.tired:
        return AppColors.alertOrange.withValues(alpha: 0.2);
      case AvatarMood.thirsty:
        return AppColors.accentBlue.withValues(alpha: 0.2);
      case AvatarMood.sad:
      case AvatarMood.worried:
        return AppColors.error.withValues(alpha: 0.2);
    }
  }
}

class AvatarFacePainter extends CustomPainter {
  final AvatarMood mood;

  AvatarFacePainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    // Draw eyes
    _drawEyes(canvas, size, paint);

    // Draw mouth based on mood
    _drawMouth(canvas, size, paint);

    // Draw optional features
    if (mood == AvatarMood.tired) {
      _drawTiredLines(canvas, size, paint);
    } else if (mood == AvatarMood.worried) {
      _drawSweatDrop(canvas, size, paint);
    }
  }

  void _drawEyes(Canvas canvas, Size size, Paint paint) {
    paint.color = AppColors.textPrimary;

    final leftEyeX = size.width * 0.35;
    final rightEyeX = size.width * 0.65;
    final eyeY = size.height * 0.4;
    final eyeSize = size.width * 0.08;

    if (mood == AvatarMood.happy || mood == AvatarMood.excited) {
      // Happy eyes (curved lines)
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;

      final leftEyePath = Path()
        ..moveTo(leftEyeX - eyeSize, eyeY - eyeSize * 0.3)
        ..quadraticBezierTo(
          leftEyeX,
          eyeY + eyeSize * 0.3,
          leftEyeX + eyeSize,
          eyeY - eyeSize * 0.3,
        );
      canvas.drawPath(leftEyePath, paint);

      final rightEyePath = Path()
        ..moveTo(rightEyeX - eyeSize, eyeY - eyeSize * 0.3)
        ..quadraticBezierTo(
          rightEyeX,
          eyeY + eyeSize * 0.3,
          rightEyeX + eyeSize,
          eyeY - eyeSize * 0.3,
        );
      canvas.drawPath(rightEyePath, paint);
    } else if (mood == AvatarMood.tired) {
      // Tired eyes (half closed)
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;

      canvas.drawLine(
        Offset(leftEyeX - eyeSize, eyeY),
        Offset(leftEyeX + eyeSize, eyeY),
        paint,
      );
      canvas.drawLine(
        Offset(rightEyeX - eyeSize, eyeY),
        Offset(rightEyeX + eyeSize, eyeY),
        paint,
      );
    } else if (mood == AvatarMood.sad || mood == AvatarMood.worried) {
      // Sad eyes (dots)
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(leftEyeX, eyeY), eyeSize * 0.7, paint);
      canvas.drawCircle(Offset(rightEyeX, eyeY), eyeSize * 0.7, paint);
    } else {
      // Normal eyes (circles)
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(leftEyeX, eyeY), eyeSize, paint);
      canvas.drawCircle(Offset(rightEyeX, eyeY), eyeSize, paint);
    }
  }

  void _drawMouth(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    paint.strokeCap = StrokeCap.round;

    final mouthY = size.height * 0.65;
    final mouthWidth = size.width * 0.3;
    final mouthHeight = size.height * 0.1;

    switch (mood) {
      case AvatarMood.happy:
      case AvatarMood.excited:
        // Big smile
        paint.color = AppColors.accentGreen;
        final smilePath = Path()
          ..moveTo(size.width * 0.35, mouthY)
          ..quadraticBezierTo(
            size.width * 0.5,
            mouthY + mouthHeight,
            size.width * 0.65,
            mouthY,
          );
        canvas.drawPath(smilePath, paint);
        break;

      case AvatarMood.normal:
        // Slight smile
        paint.color = AppColors.primaryTeal;
        final normalPath = Path()
          ..moveTo(size.width * 0.4, mouthY)
          ..quadraticBezierTo(
            size.width * 0.5,
            mouthY + mouthHeight * 0.5,
            size.width * 0.6,
            mouthY,
          );
        canvas.drawPath(normalPath, paint);
        break;

      case AvatarMood.tired:
        // Straight line
        paint.color = AppColors.alertOrange;
        canvas.drawLine(
          Offset(size.width * 0.4, mouthY),
          Offset(size.width * 0.6, mouthY),
          paint,
        );
        break;

      case AvatarMood.thirsty:
        // Small O shape
        paint.color = AppColors.accentBlue;
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width * 0.5, mouthY),
          mouthWidth * 0.3,
          paint,
        );
        break;

      case AvatarMood.sad:
      case AvatarMood.worried:
        // Sad mouth (inverted smile)
        paint.color = AppColors.error;
        final sadPath = Path()
          ..moveTo(size.width * 0.35, mouthY)
          ..quadraticBezierTo(
            size.width * 0.5,
            mouthY - mouthHeight * 0.7,
            size.width * 0.65,
            mouthY,
          );
        canvas.drawPath(sadPath, paint);
        break;
    }
  }

  void _drawTiredLines(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = AppColors.textSecondary.withValues(alpha: 0.5);

    // Lines under eyes
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final lineY = size.height * 0.45;
    final lineLength = size.width * 0.08;

    for (int i = 0; i < 2; i++) {
      canvas.drawLine(
        Offset(leftX, lineY + i * 4),
        Offset(leftX + lineLength, lineY + i * 4),
        paint,
      );
      canvas.drawLine(
        Offset(rightX - lineLength, lineY + i * 4),
        Offset(rightX, lineY + i * 4),
        paint,
      );
    }
  }

  void _drawSweatDrop(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = AppColors.accentBlue;

    final dropX = size.width * 0.75;
    final dropY = size.height * 0.35;
    final dropSize = size.width * 0.08;

    final dropPath = Path()
      ..moveTo(dropX, dropY)
      ..quadraticBezierTo(
        dropX - dropSize * 0.5,
        dropY - dropSize,
        dropX,
        dropY - dropSize * 1.5,
      )
      ..quadraticBezierTo(
        dropX + dropSize * 0.5,
        dropY - dropSize,
        dropX,
        dropY,
      );
    canvas.drawPath(dropPath, paint);
  }

  @override
  bool shouldRepaint(AvatarFacePainter oldDelegate) => oldDelegate.mood != mood;
}

class AvatarMoodHelper {
  static AvatarMood determineMood({
    required double stepsProgress,
    required double waterProgress,
    required double calorieProgress,
    required int activityCount,
  }) {
    final avgProgress = (stepsProgress + waterProgress + calorieProgress) / 3;

    // Thirsty check (water is most important)
    if (waterProgress < 0.3) {
      return AvatarMood.thirsty;
    }

    // Excited - All goals exceeded
    if (avgProgress >= 0.9 && activityCount >= 2) {
      return AvatarMood.excited;
    }

    // Happy - Good progress
    if (avgProgress >= 0.7) {
      return AvatarMood.happy;
    }

    // Normal - Average progress
    if (avgProgress >= 0.4) {
      return AvatarMood.normal;
    }

    // Tired - Low activity
    if (stepsProgress < 0.3 && activityCount == 0) {
      return AvatarMood.tired;
    }

    // Worried - Very low progress
    if (avgProgress < 0.2) {
      return AvatarMood.worried;
    }

    // Sad - Below average
    return AvatarMood.sad;
  }

  static String getMoodMessage(AvatarMood mood) {
    switch (mood) {
      case AvatarMood.excited:
        return 'Harika gidiyorsun! 🎉';
      case AvatarMood.happy:
        return 'Çok iyi! Devam et! 😊';
      case AvatarMood.normal:
        return 'İyi gidiyorsun! 👍';
      case AvatarMood.tired:
        return 'Biraz hareket etmeye ne dersin? 🚶';
      case AvatarMood.thirsty:
        return 'Su içmeyi unutma! 💧';
      case AvatarMood.sad:
        return 'Hadi biraz daha çaba gösterelim! 💪';
      case AvatarMood.worried:
        return 'Küçük adımlarla başlayalım! 🌱';
    }
  }
}
