# 🎮 BodyEcho Oyunlaştırma Sistemi - Kurulum Kılavuzu

## 📋 Özet

BodyEcho uygulamasına kullanıcıların etkileşimleriyle puan, seviye ve rozet kazanabilecekleri kapsamlı bir oyunlaştırma sistemi eklendi.

## ✅ Tamamlanan Özellikler

### 1. 📊 Puan Sistemi
- **Temel Aksiyonlar:**
  - Aktivite ekleme: 20 puan
  - Su ekleme: 5 puan
  - Uyku kaydı: 10 puan
  - Sağlık kaydı: 15 puan

- **Günlük Hedef Tamamlama:**
  - 10,000 adım: 50 puan
  - 2.5L su: 30 puan
  - 8 saat uyku: 25 puan
  - 2,500 kalori: 40 puan
  - Perfect Day (hepsi): +50 bonus

- **Özel Bonuslar:**
  - Sabah erken aktivite (07:00 öncesi): +10 puan
  - Hafta sonu aktivitesi: +15 puan
  - Streak bonusları: 50-2,500 puan

### 2. 🏆 30+ Rozet
- **Aktivite Rozetleri:** İlk Adım 🚶, 5km Yürüyüşçü 🏃, 100km Ustası 🏆, 500km Efsanesi 💎
- **Sağlık Rozetleri:** Su İçici 💧, Uyku Uzmanı 🛌, Adım Efsanesi 🏃
- **Streak Rozetleri:** 3 Gün 🔥, 7 Gün 🔥🔥, 30 Gün 🔥🔥🔥, 100 Gün 💪, 365 Gün 👑
- **Hedef Rozetleri:** İlk Hedef ✅, Hedef Avcısı 🎯, Mükemmeliyetçi 🏆
- **Özel Rozetler:** Erken Kuş 🌅, Hafta Sonu Savaşçısı 🎉, Veri Bilimci 📊

### 3. 🎯 Seviye Sistemi
- 500 puan = 1 seviye
- Seviye başlıkları:
  - 1-4: Acemi
  - 5-9: Sporcu
  - 10-19: Uzman
  - 20-29: Şampiyon
  - 30-49: Efsane
  - 50+: Süper Kahraman

### 4. 🔥 Streak (Seri) Sistemi
- Günlük aktivite takibi
- Streak bonusları ve rozetleri
- En uzun streak kaydı

## 🗂️ Eklenen Dosyalar

### Models
- `lib/models/gamification_stats_model.dart` - İstatistik modeli
- `lib/models/badge_model.dart` - Rozet modelleri

### Services
- `lib/services/gamification_service.dart` - Ana gamification servisi
- `lib/services/badge_definitions_service.dart` - Rozet tanımları

### Widgets
- `lib/widgets/points_toast_widget.dart` - Puan bildirimi
- `lib/widgets/badge_unlock_dialog.dart` - Rozet kazanma dialogu
- `lib/features/profile/widgets/badge_gallery_widget.dart` - Rozet galerisi

### Utils
- `lib/utils/init_gamification.dart` - İlk kurulum scripti

## 📝 Güncellenen Dosyalar

1. **lib/models/user_model.dart**
   - `totalPoints`, `currentStreak`, `longestStreak`, `lastActiveDate`, `unlockedBadges` alanları eklendi

2. **lib/config/app_constants.dart**
   - `getLevelTitle()` metodu eklendi

3. **lib/features/profile/views/profile_screen.dart**
   - Seviye rozeti ve circular progress
   - Puan göstergesi
   - Streak göstergesi
   - Rozet galerisi

4. **lib/features/home/viewmodels/home_provider.dart**
   - Gamification entegrasyonu (puan verme, streak güncelleme)

5. **lib/features/activity/viewmodels/activity_provider.dart**
   - Aktivite puanları ve rozet kontrolleri

6. **lib/features/home/views/home_screen.dart**
   - AppBar'a puan göstergesi eklendi

## 🚀 İlk Kurulum

### Adım 1: Rozetleri Firestore'a Yükle

Uygulamayı ilk kez çalıştırmadan önce, rozetleri Firestore'a yüklemeniz gerekir.

**Option A: Kod ile yükleme (Önerilen)**

Ana uygulama başlangıcında (örn: `main.dart` veya login sonrası):

```dart
import 'package:bodyecho/utils/init_gamification.dart';

// Uygulamanın ilk başlatılışında bir kez çalıştır
await GamificationInitializer.initialize();
```

**Option B: Debug menüsünden manuel**

Settings sayfasına bir "Initialize Gamification" butonu ekleyebilirsiniz (sadece debug modda).

### Adım 2: Mevcut Kullanıcıları Güncelle

Mevcut kullanıcılar için gamification alanlarını başlatmak gerekir. Firebase Console'dan veya migration script ile:

```javascript
// Firebase Console > Firestore > users collection
// Her kullanıcı için şu alanları ekle:
{
  "totalPoints": 0,
  "currentStreak": 0,
  "longestStreak": 0,
  "lastActiveDate": null,
  "unlockedBadges": []
}
```

## 🔧 Firestore Yapısı

```
firestore/
├── users/{userId}
│   ├── totalPoints: number
│   ├── currentStreak: number
│   ├── longestStreak: number
│   ├── lastActiveDate: timestamp
│   └── unlockedBadges: array<string>
│
├── badgeDefinitions/{badgeId}
│   ├── id: string
│   ├── category: string
│   ├── title: string
│   ├── description: string
│   ├── icon: string (emoji)
│   ├── tier: number (1-4)
│   └── condition: map
│
├── userBadges/{userId}/badges/{badgeId}
│   ├── badgeId: string
│   ├── earnedDate: timestamp
│   └── notified: boolean
│
└── gamificationStats/{userId}
    ├── totalDistanceKm: number
    ├── totalActivities: number
    ├── waterGoalDaysCount: number
    ├── stepsGoalDaysCount: number
    ├── sleepGoalDaysCount: number
    ├── perfectDaysCount: number
    └── lastUpdated: timestamp
```

## 🔒 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /badgeDefinitions/{badgeId} {
      allow read: if request.auth != null;
      allow write: if false; // Sadece admin
    }

    match /userBadges/{userId}/badges/{badgeId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Sadece server-side
    }

    match /gamificationStats/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Sadece server-side
    }
  }
}
```

## 📱 Kullanıcı Deneyimi

### Profil Ekranı
- Kullanıcı avatarı etrafında seviye ilerlemesi (circular progress)
- Seviye rozeti (LVL 5)
- Toplam puan ve seviye başlığı
- Mevcut streak göstergesi (🔥 15 Gün Serisi)
- Rozet galerisi (kazanılan/kilitli rozetler)

### Ana Ekran
- AppBar'da puan göstergesi (altın renk)
- Her aksiyondan sonra puan toast bildirimi (gelecek güncellemede)

### Rozet Kazanma
- Rozet açıldığında kutlama dialogu
- Rozet ikonu, adı, açıklaması
- Tier göstergesi (Bronz/Gümüş/Altın/Platin)

## 🎯 Sonraki Adımlar (İsteğe Bağlı)

1. **Points Toast Gösterimi**
   - Puan kazanıldığında toast göster
   - HomeProvider ve ActivityProvider'a toast çağrıları ekle

2. **Badge Unlock Dialog Gösterimi**
   - Rozet açıldığında dialog göster
   - Animasyon ve confetti efektleri

3. **Liderlik Tablosu** (Opsiyonel)
   - Haftalık/aylık puan sıralaması
   - Arkadaşlarla karşılaştırma

4. **Push Bildirimleri**
   - Rozet kazanma bildirimleri
   - Streak hatırlatıcıları
   - Günlük hedef hatırlatmaları

## 🧪 Test

### Manuel Test Senaryosu

1. **Aktivite Ekle**
   - Aktivite ekle
   - Console'da puanların verildiğini kontrol et
   - Profile git, puanların arttığını gör
   - İlk aktivite rozetinin açıldığını kontrol et

2. **Günlük Hedefler**
   - 10,000 adım ekle → 50 puan
   - 2.5L su ekle → 5x5=25 puan + 30 puan = 55 puan
   - 8 saat uyku ekle → 10 + 25 = 35 puan
   - Perfect day kontrolü

3. **Streak**
   - Birkaç gün üst üste aktivite ekle
   - Streak sayısının arttığını kontrol et
   - 3 gün streak rozetini kazandığını gör

4. **Rozet Galerisi**
   - Profile git
   - Kazanılan rozetlerin renkli, diğerlerinin gri olduğunu gör
   - Rozete tıkla, detayları gör

## 📊 Metrikler

Sistemin başarısını ölçmek için:
- Günlük aktif kullanıcı sayısı
- Ortalama kullanıcı başına günlük puan
- 7+ gün streak'e sahip kullanıcı oranı
- Rozet unlock oranı
- Kullanıcı seviye dağılımı

## 🐛 Bilinen Sorunlar

Şu anda bilinen sorun yok. Sorun bulursanız lütfen bildirin.

## 📞 Destek

Sorularınız için:
- GitHub Issues
- Email: support@bodyecho.app

---

**🎉 Başarılar! Kullanıcılarınız artık puanlar, rozetler ve seviyeler kazanabilir!**
