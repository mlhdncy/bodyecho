import 'package:flutter/material.dart';

enum AvatarMood {
  happy, // Tüm hedefler tamamlanmış
  excited, // Hedeflerin üzerinde
  normal, // Ortalama ilerleme
  tired, // Az aktivite
  thirsty, // Su eksik
  sad, // Hedeflere uzak
  worried, // Çok düşük aktivite
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
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          _getAvatarImagePath(),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _getAvatarImagePath() {
    switch (mood) {
      case AvatarMood.happy:
        return 'avatar/iyi_spor.png';
      case AvatarMood.excited:
        return 'avatar/spor_2.png';
      case AvatarMood.normal:
        return 'avatar/spor_2.png';
      case AvatarMood.tired:
        return 'avatar/uyku_sorunu.png';
      case AvatarMood.thirsty:
        return 'avatar/az_su_tuketimi.png';
      case AvatarMood.sad:
        return 'avatar/kotu_istatistik.png';
      case AvatarMood.worried:
        return 'avatar/kilo_alma_tehditi.png';
    }
  }
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
