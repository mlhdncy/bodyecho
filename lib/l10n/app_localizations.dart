import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// Application title
  ///
  /// In tr, this message translates to:
  /// **'Body Echo'**
  String get appTitle;

  /// Application subtitle
  ///
  /// In tr, this message translates to:
  /// **'Sağlık ve Wellness Takibi'**
  String get appSubtitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kaydol'**
  String get register;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In tr, this message translates to:
  /// **'GİRİŞ'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? '**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? '**
  String get haveAccount;

  /// No description provided for @fullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Adınız Soyadınız'**
  String get fullNameHint;

  /// No description provided for @confirmPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get confirmPassword;

  /// No description provided for @age.
  ///
  /// In tr, this message translates to:
  /// **'Yaş'**
  String get age;

  /// No description provided for @ageHint.
  ///
  /// In tr, this message translates to:
  /// **'Yaşınız'**
  String get ageHint;

  /// No description provided for @height.
  ///
  /// In tr, this message translates to:
  /// **'Boy (cm)'**
  String get height;

  /// No description provided for @heightHint.
  ///
  /// In tr, this message translates to:
  /// **'Boyunuz'**
  String get heightHint;

  /// No description provided for @weight.
  ///
  /// In tr, this message translates to:
  /// **'Kilo (kg)'**
  String get weight;

  /// No description provided for @weightHint.
  ///
  /// In tr, this message translates to:
  /// **'Kilonuz'**
  String get weightHint;

  /// No description provided for @gender.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get male;

  /// No description provided for @female.
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get female;

  /// No description provided for @other.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get other;

  /// No description provided for @registerButton.
  ///
  /// In tr, this message translates to:
  /// **'KAYIT OL'**
  String get registerButton;

  /// No description provided for @emailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi gerekli'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalı'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordsDoNotMatch;

  /// No description provided for @fullNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad gerekli'**
  String get fullNameRequired;

  /// No description provided for @ageRequired.
  ///
  /// In tr, this message translates to:
  /// **'Yaş gerekli'**
  String get ageRequired;

  /// No description provided for @heightRequired.
  ///
  /// In tr, this message translates to:
  /// **'Boy gerekli'**
  String get heightRequired;

  /// No description provided for @weightRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kilo gerekli'**
  String get weightRequired;

  /// No description provided for @genderRequired.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet seçimi gerekli'**
  String get genderRequired;

  /// No description provided for @loginFailed.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız'**
  String get registrationFailed;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// No description provided for @activity.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite'**
  String get activity;

  /// No description provided for @nutrition.
  ///
  /// In tr, this message translates to:
  /// **'Beslenme'**
  String get nutrition;

  /// No description provided for @reports.
  ///
  /// In tr, this message translates to:
  /// **'Raporlar'**
  String get reports;

  /// No description provided for @trends.
  ///
  /// In tr, this message translates to:
  /// **'Trendler'**
  String get trends;

  /// No description provided for @chat.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet'**
  String get chat;

  /// No description provided for @level.
  ///
  /// In tr, this message translates to:
  /// **'LVL'**
  String get level;

  /// No description provided for @points.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get points;

  /// No description provided for @streak.
  ///
  /// In tr, this message translates to:
  /// **'Gün Serisi'**
  String get streak;

  /// No description provided for @user.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get user;

  /// No description provided for @physicalInfo.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel Bilgiler'**
  String get physicalInfo;

  /// No description provided for @heightLabel.
  ///
  /// In tr, this message translates to:
  /// **'Boy'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kilo'**
  String get weightLabel;

  /// No description provided for @ageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yaş'**
  String get ageLabel;

  /// No description provided for @aiHealthRiskAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'AI Sağlık Risk Analizi'**
  String get aiHealthRiskAnalysis;

  /// No description provided for @viewBodyRiskMap.
  ///
  /// In tr, this message translates to:
  /// **'Vücut risk haritanızı görüntüleyin'**
  String get viewBodyRiskMap;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik'**
  String get privacy;

  /// No description provided for @helpSupport.
  ///
  /// In tr, this message translates to:
  /// **'Yardım & Destek'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinize emin misiniz?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @personalInfo.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Bilgiler'**
  String get personalInfo;

  /// No description provided for @healthGoals.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık Hedefleri'**
  String get healthGoals;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri Kaydet'**
  String get saveChanges;

  /// No description provided for @dailyGoals.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hedefler'**
  String get dailyGoals;

  /// No description provided for @waterIntake.
  ///
  /// In tr, this message translates to:
  /// **'Su Tüketimi'**
  String get waterIntake;

  /// No description provided for @steps.
  ///
  /// In tr, this message translates to:
  /// **'Adım'**
  String get steps;

  /// No description provided for @calories.
  ///
  /// In tr, this message translates to:
  /// **'Kalori'**
  String get calories;

  /// No description provided for @sleep.
  ///
  /// In tr, this message translates to:
  /// **'Uyku'**
  String get sleep;

  /// No description provided for @todayProgress.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün İlerlemesi'**
  String get todayProgress;

  /// No description provided for @weeklyProgress.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık İlerleme'**
  String get weeklyProgress;

  /// No description provided for @monthlyProgress.
  ///
  /// In tr, this message translates to:
  /// **'Aylık İlerleme'**
  String get monthlyProgress;

  /// No description provided for @addActivity.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite Ekle'**
  String get addActivity;

  /// No description provided for @activityLog.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite Geçmişi'**
  String get activityLog;

  /// No description provided for @activityType.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite Türü'**
  String get activityType;

  /// No description provided for @duration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get duration;

  /// No description provided for @minutes.
  ///
  /// In tr, this message translates to:
  /// **'dakika'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In tr, this message translates to:
  /// **'saat'**
  String get hours;

  /// No description provided for @distance.
  ///
  /// In tr, this message translates to:
  /// **'Mesafe'**
  String get distance;

  /// No description provided for @km.
  ///
  /// In tr, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @calorieTracking.
  ///
  /// In tr, this message translates to:
  /// **'Kalori Takibi'**
  String get calorieTracking;

  /// No description provided for @breakfast.
  ///
  /// In tr, this message translates to:
  /// **'Kahvaltı'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In tr, this message translates to:
  /// **'Öğle Yemeği'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In tr, this message translates to:
  /// **'Akşam Yemeği'**
  String get dinner;

  /// No description provided for @snacks.
  ///
  /// In tr, this message translates to:
  /// **'Atıştırmalıklar'**
  String get snacks;

  /// No description provided for @addFood.
  ///
  /// In tr, this message translates to:
  /// **'Yiyecek Ekle'**
  String get addFood;

  /// No description provided for @searchFood.
  ///
  /// In tr, this message translates to:
  /// **'Yiyecek Ara'**
  String get searchFood;

  /// No description provided for @dailyReport.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Rapor'**
  String get dailyReport;

  /// No description provided for @weeklyReport.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Rapor'**
  String get weeklyReport;

  /// No description provided for @monthlyReport.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Rapor'**
  String get monthlyReport;

  /// No description provided for @generateReport.
  ///
  /// In tr, this message translates to:
  /// **'Rapor Oluştur'**
  String get generateReport;

  /// No description provided for @healthTrends.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık Trendleri'**
  String get healthTrends;

  /// No description provided for @weightTrend.
  ///
  /// In tr, this message translates to:
  /// **'Kilo Trendi'**
  String get weightTrend;

  /// No description provided for @activityTrend.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite Trendi'**
  String get activityTrend;

  /// No description provided for @nutritionTrend.
  ///
  /// In tr, this message translates to:
  /// **'Beslenme Trendi'**
  String get nutritionTrend;

  /// No description provided for @badges.
  ///
  /// In tr, this message translates to:
  /// **'Rozetler'**
  String get badges;

  /// No description provided for @achievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar'**
  String get achievements;

  /// No description provided for @unlocked.
  ///
  /// In tr, this message translates to:
  /// **'Kazanıldı'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli'**
  String get locked;

  /// No description provided for @badgeUnlocked.
  ///
  /// In tr, this message translates to:
  /// **'Rozet Kazanıldı!'**
  String get badgeUnlocked;

  /// No description provided for @congratulations.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler!'**
  String get congratulations;

  /// No description provided for @aiChat.
  ///
  /// In tr, this message translates to:
  /// **'AI Sohbet'**
  String get aiChat;

  /// No description provided for @askQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Soru sorun...'**
  String get askQuestion;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçin'**
  String get selectLanguage;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @cm.
  ///
  /// In tr, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @kg.
  ///
  /// In tr, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @ml.
  ///
  /// In tr, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @kcal.
  ///
  /// In tr, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @welcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin!'**
  String get welcome;

  /// No description provided for @settingsAndProfile.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar & Profil'**
  String get settingsAndProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi!'**
  String get profileUpdated;

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Hata:'**
  String get errorOccurred;

  /// No description provided for @validHeight.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir boy giriniz'**
  String get validHeight;

  /// No description provided for @validWeight.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir kilo giriniz'**
  String get validWeight;

  /// No description provided for @validAge.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir yaş giriniz'**
  String get validAge;

  /// No description provided for @updateInfoMessage.
  ///
  /// In tr, this message translates to:
  /// **'Daha doğru sağlık analizleri için lütfen bilgilerinizi güncelleyin.'**
  String get updateInfoMessage;

  /// No description provided for @gamificationSystem.
  ///
  /// In tr, this message translates to:
  /// **'Oyunlaştırma Sistemi'**
  String get gamificationSystem;

  /// No description provided for @loadBadges.
  ///
  /// In tr, this message translates to:
  /// **'Rozetleri Yükle'**
  String get loadBadges;

  /// No description provided for @badgesLoadedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'✅ Rozetler başarıyla yüklendi! 30+ rozet Firestore\'a eklendi.'**
  String get badgesLoadedSuccess;

  /// No description provided for @initializeMessage.
  ///
  /// In tr, this message translates to:
  /// **'Rozetleri ve oyunlaştırma sistemini başlatmak için butona basın. (Sadece ilk kurulumda bir kez çalıştırın)'**
  String get initializeMessage;

  /// No description provided for @noActivitiesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz aktivite yok'**
  String get noActivitiesYet;

  /// No description provided for @startTrackingMessage.
  ///
  /// In tr, this message translates to:
  /// **'İlk aktivitenizi ekleyerek başlayın!'**
  String get startTrackingMessage;

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @deleteActivity.
  ///
  /// In tr, this message translates to:
  /// **'Aktiviteyi Sil'**
  String get deleteActivity;

  /// No description provided for @deleteActivityConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu aktiviteyi silmek istediğinize emin misiniz?'**
  String get deleteActivityConfirm;

  /// No description provided for @activityDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite silindi'**
  String get activityDeleted;

  /// No description provided for @selectActivityType.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite türü seçin'**
  String get selectActivityType;

  /// No description provided for @enterDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre girin (dakika)'**
  String get enterDuration;

  /// No description provided for @enterDistance.
  ///
  /// In tr, this message translates to:
  /// **'Mesafe girin (km)'**
  String get enterDistance;

  /// No description provided for @optional.
  ///
  /// In tr, this message translates to:
  /// **'Opsiyonel'**
  String get optional;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @activityAdded.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite eklendi!'**
  String get activityAdded;

  /// No description provided for @fillAllFields.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm alanları doldurun'**
  String get fillAllFields;

  /// No description provided for @running.
  ///
  /// In tr, this message translates to:
  /// **'Koşu'**
  String get running;

  /// No description provided for @walking.
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get walking;

  /// No description provided for @cycling.
  ///
  /// In tr, this message translates to:
  /// **'Bisiklet'**
  String get cycling;

  /// No description provided for @swimming.
  ///
  /// In tr, this message translates to:
  /// **'Yüzme'**
  String get swimming;

  /// No description provided for @yoga.
  ///
  /// In tr, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @gym.
  ///
  /// In tr, this message translates to:
  /// **'Spor Salonu'**
  String get gym;

  /// No description provided for @todayCalories.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Kalorisi'**
  String get todayCalories;

  /// No description provided for @target.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get target;

  /// No description provided for @consumed.
  ///
  /// In tr, this message translates to:
  /// **'Tüketilen'**
  String get consumed;

  /// No description provided for @remaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get remaining;

  /// No description provided for @mealBreakdown.
  ///
  /// In tr, this message translates to:
  /// **'Öğün Dağılımı'**
  String get mealBreakdown;

  /// No description provided for @recentFoods.
  ///
  /// In tr, this message translates to:
  /// **'Son Eklenen Yiyecekler'**
  String get recentFoods;

  /// No description provided for @noFoodsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yiyecek eklenmedi'**
  String get noFoodsYet;

  /// No description provided for @startAddingMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yiyecek ekleyerek başlayın!'**
  String get startAddingMessage;

  /// No description provided for @serving.
  ///
  /// In tr, this message translates to:
  /// **'porsiyon'**
  String get serving;

  /// No description provided for @searchFoodPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Yiyecek ara (örn: elma, tavuk)...'**
  String get searchFoodPlaceholder;

  /// No description provided for @searching.
  ///
  /// In tr, this message translates to:
  /// **'Aranıyor...'**
  String get searching;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir arama deneyin'**
  String get tryDifferentSearch;

  /// No description provided for @selectMeal.
  ///
  /// In tr, this message translates to:
  /// **'Öğün seçin'**
  String get selectMeal;

  /// No description provided for @servings.
  ///
  /// In tr, this message translates to:
  /// **'Porsiyon sayısı'**
  String get servings;

  /// No description provided for @foodAdded.
  ///
  /// In tr, this message translates to:
  /// **'Yiyecek eklendi!'**
  String get foodAdded;

  /// No description provided for @healthReports.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık Raporları'**
  String get healthReports;

  /// No description provided for @viewReportsMessage.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık verilerinizi detaylı raporlarla inceleyin'**
  String get viewReportsMessage;

  /// No description provided for @daily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get monthly;

  /// No description provided for @viewReport.
  ///
  /// In tr, this message translates to:
  /// **'Raporu Görüntüle'**
  String get viewReport;

  /// No description provided for @overview.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış'**
  String get overview;

  /// No description provided for @waterGoal.
  ///
  /// In tr, this message translates to:
  /// **'Su Hedefi'**
  String get waterGoal;

  /// No description provided for @stepsGoal.
  ///
  /// In tr, this message translates to:
  /// **'Adım Hedefi'**
  String get stepsGoal;

  /// No description provided for @caloriesGoal.
  ///
  /// In tr, this message translates to:
  /// **'Kalori Hedefi'**
  String get caloriesGoal;

  /// No description provided for @activitiesCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan Aktiviteler'**
  String get activitiesCompleted;

  /// No description provided for @totalDuration.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre'**
  String get totalDuration;

  /// No description provided for @totalDistance.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Mesafe'**
  String get totalDistance;

  /// No description provided for @nutritionSummary.
  ///
  /// In tr, this message translates to:
  /// **'Beslenme Özeti'**
  String get nutritionSummary;

  /// No description provided for @totalCalories.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Kalori'**
  String get totalCalories;

  /// No description provided for @mealsLogged.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen Öğün'**
  String get mealsLogged;

  /// No description provided for @weekOf.
  ///
  /// In tr, this message translates to:
  /// **'Hafta:'**
  String get weekOf;

  /// No description provided for @averageDaily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Ortalama'**
  String get averageDaily;

  /// No description provided for @totalForWeek.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Toplam'**
  String get totalForWeek;

  /// No description provided for @mostActiveDay.
  ///
  /// In tr, this message translates to:
  /// **'En Aktif Gün'**
  String get mostActiveDay;

  /// No description provided for @monthOf.
  ///
  /// In tr, this message translates to:
  /// **'Ay:'**
  String get monthOf;

  /// No description provided for @averagePerDay.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Ortalama'**
  String get averagePerDay;

  /// No description provided for @totalForMonth.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Toplam'**
  String get totalForMonth;

  /// No description provided for @bestDay.
  ///
  /// In tr, this message translates to:
  /// **'En İyi Gün'**
  String get bestDay;

  /// No description provided for @healthTrendsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık Trendleri'**
  String get healthTrendsTitle;

  /// No description provided for @trackProgressMessage.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık metriklerinizi zaman içinde takip edin'**
  String get trackProgressMessage;

  /// No description provided for @last7Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 Gün'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 30 Gün'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 90 Gün'**
  String get last90Days;

  /// No description provided for @bodyRiskMap.
  ///
  /// In tr, this message translates to:
  /// **'Vücut Risk Haritası'**
  String get bodyRiskMap;

  /// No description provided for @aiAnalysisMessage.
  ///
  /// In tr, this message translates to:
  /// **'AI destekli sağlık risk analizi'**
  String get aiAnalysisMessage;

  /// No description provided for @riskLevel.
  ///
  /// In tr, this message translates to:
  /// **'Risk Seviyesi'**
  String get riskLevel;

  /// No description provided for @low.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get high;

  /// No description provided for @recommendations.
  ///
  /// In tr, this message translates to:
  /// **'Öneriler'**
  String get recommendations;

  /// No description provided for @noDataAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Veri mevcut değil'**
  String get noDataAvailable;

  /// No description provided for @addDataMessage.
  ///
  /// In tr, this message translates to:
  /// **'Analiz için lütfen sağlık verilerinizi ekleyin'**
  String get addDataMessage;

  /// No description provided for @aiHealthAssistant.
  ///
  /// In tr, this message translates to:
  /// **'AI Sağlık Asistanı'**
  String get aiHealthAssistant;

  /// No description provided for @askAnything.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık ve wellness hakkında herhangi bir şey sorun'**
  String get askAnything;

  /// No description provided for @typeMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınızı yazın...'**
  String get typeMessage;

  /// No description provided for @exampleQuestions.
  ///
  /// In tr, this message translates to:
  /// **'Örnek Sorular:'**
  String get exampleQuestions;

  /// No description provided for @howMuchWater.
  ///
  /// In tr, this message translates to:
  /// **'Günde ne kadar su içmeliyim?'**
  String get howMuchWater;

  /// No description provided for @healthyBreakfast.
  ///
  /// In tr, this message translates to:
  /// **'Sağlıklı kahvaltı önerileri neler?'**
  String get healthyBreakfast;

  /// No description provided for @improveSteps.
  ///
  /// In tr, this message translates to:
  /// **'Adım sayımı nasıl artırabilirim?'**
  String get improveSteps;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @remove.
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get remove;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
