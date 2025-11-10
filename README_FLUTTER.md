# Body Echo - Flutter Cross-Platform App

Body Echo artık **Flutter** ile geliştirilmektedir! iOS, Android ve Web'de çalışan tek bir codebase.

## 🎯 Proje Durumu

### ✅ Tamamlanan

1. **Proje Yapısı**
   - Flutter projesi oluşturuldu (iOS, Android, Web)
   - Clean Architecture ile klasör yapısı
   - MVVM pattern uygulandı

2. **Design System**
   - Body Echo brand renkleri tanımlandı
   - AppTheme oluşturuldu (Material 3)
   - UI constants belirlendi

3. **Custom Widgets**
   - `CustomButton` - Primary, Secondary, Outline styles
   - `CustomTextField` - Label, şifre görünürlük toggle
   - `CircularProgressWidget` - Günlük metrikler için
   - `ProgressBarWidget` - Linear progress göstergeleri

4. **Firebase Integration**
   - Models: User, DailyMetric, Activity
   - Services: Auth, Firestore, Anonymization
   - Veri anonimleştirme (SHA-256)

5. **Dependencies**
   - Firebase: Auth, Firestore, Storage, Analytics
   - Provider: State management
   - FL Chart: Health trend grafikleri
   - Crypto: Veri güvenliği

### 🚧 Devam Eden

6. **Authentication Screens** (Sırada)
   - Login View
   - Registration View
   - Auth Provider

7. **Home Screen** (Sırada)
   - Daily Goals Widget
   - AI Insights
   - Avatar with level/points

8. **Diğer Ekranlar** (Sırada)
   - Activity Log
   - Trends
   - Profile & Settings

### 📋 Yapılacaklar

- [ ] Firebase FlutterFire CLI ile yapılandırma
- [ ] Authentication ekranları
- [ ] Home screen & daily metrics
- [ ] Activity logging
- [ ] Trends & charts
- [ ] Profile & settings
- [ ] Platform-specific icons & splash
- [ ] Web deployment (Firebase Hosting)
- [ ] Android deployment (Google Play)
- [ ] iOS deployment (App Store)

## 🎨 Design System

### Brand Colors

```dart
Primary: #4CC9B0, #6ED1C8 (Teal/Turkuaz)
Secondary: #A7D7C5, #B8E1DD
Background: #F5F7FA
Buttons: #2E9E9A, #247A76
Alerts: #F66A4B, #FF9F68
Avatar: #FADADD, #F6C6C6 (Pink)
```

### Logo

Body Echo logosu: Yoga pozu + kalp + EKG dalga formları

## 🚀 Kurulum

### 1. Dependencies Yükle

```bash
flutter pub get
```

### 2. Firebase Yapılandırması

```bash
# Firebase CLI kur (eğer yoksa)
npm install -g firebase-tools

# Firebase'e login
firebase login

# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# Firebase projesi yapılandır
flutterfire configure
```

### 3. Çalıştır

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome

# Tüm platform build'leri
flutter build ios
flutter build apk
flutter build web
```

## 📱 Platformlar

- **iOS**: ✅ Hazır (iOS 16+)
- **Android**: ✅ Hazır (API 21+)
- **Web**: ✅ Hazır (modern browsers)

## 📂 Proje Yapısı

```
lib/
├── config/
│   ├── app_colors.dart      # Brand renkleri
│   ├── app_theme.dart       # Material 3 theme
│   └── app_constants.dart   # Sabitler
├── models/
│   ├── user_model.dart
│   ├── daily_metric_model.dart
│   └── activity_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── anonymization_service.dart
├── widgets/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── circular_progress_widget.dart
│   └── progress_bar_widget.dart
├── core/
│   ├── authentication/
│   ├── home/
│   ├── trends/
│   ├── activity_log/
│   └── profile/
└── main.dart
```

## 🔥 Firebase Collections

### users/
- anonymousId
- fullName (anonimleştirilmiş)
- email (anonimleştirilmiş)
- level, points
- avatarType

### dailyMetrics/
- userId (anonymous)
- date
- steps, waterIntake
- calorieEstimate, sleepQuality

### activities/
- userId (anonymous)
- type (walking, running, cycling)
- duration, distance
- caloriesBurned

## 🎯 Özellikler

- ✅ Cross-platform (iOS, Android, Web)
- ✅ Firebase backend
- ✅ Veri anonimleştirme
- ✅ Material 3 design
- ✅ Responsive UI
- ✅ State management (Provider)
- ✅ Offline support (Firestore cache)

## 📝 Notlar

- **iOS Backup**: `ios-backup/` klasöründe SwiftUI kodu saklanıyor
- **Firebase**: `GoogleService-Info.plist` ve `google-services.json` eklenecek
- **Bundle ID**: `com.melih.bodyecho`

## 🚀 Deployment

### iOS (TestFlight/App Store)
1. Xcode'da proje aç: `open ios/Runner.xcworkspace`
2. Signing ayarla
3. Archive al
4. TestFlight'a yükle

### Android (Google Play)
```bash
flutter build appbundle
# Release: build/app/outputs/bundle/release/app-release.aab
```

### Web (Firebase Hosting)
```bash
flutter build web
firebase deploy --only hosting
```

## 📚 Kaynaklar

- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Material Design 3](https://m3.material.io/)

---

**Body Echo - Sağlık ve Wellness Takibi** 🧘‍♀️💚
