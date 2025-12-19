# BodyEcho: Kişisel Sağlık Asistanınız

[![Flutter Test](https://github.com/kullanici/bodyecho/actions/workflows/flutter-test.yml/badge.svg)](https://github.com/kullanici/bodyecho/actions/workflows/flutter-test.yml)
[![Deploy](https://github.com/kullanici/bodyecho/actions/workflows/deploy.yml/badge.svg)](https://github.com/kullanici/bodyecho/actions/workflows/deploy.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**BodyEcho**, kullanıcıların sağlık verilerini takip etmelerini, analiz etmelerini ve makine öğrenmesi modelleri aracılığıyla potansiyel sağlık riskleri hakkında öngörüler almalarını sağlayan kapsamlı bir mobil sağlık uygulamasıdır. Bu proje, **Yönetim Bilişim Sistemleri (YBS)** lisans programı bitirme projesi olarak geliştirilmiştir. Uygulama, modern teknolojileri kullanarak kullanıcıların daha sağlıklı bir yaşam tarzı benimsemelerine yardımcı olmayı hedefler.

---

## İçindekiler

- [Projenin Amacı](#projenin-amacı)
- [Temel Özellikler](#temel-özellikler)
- [Uygulama Akışı ve Ekranlar](#uygulama-akışı-ve-ekranlar)
  - [Giriş ve Kayıt](#giriş-ve-kayıt)
  - [Ana Panel (Dashboard)](#ana-panel-dashboard)
  - [Veri Giriş Akışı (Besin, Su, Aktivite)](#veri-giriş-akışı-besin-su-aktivite)
  - [Sağlık Analizi ve Raporlar](#sağlık-analizi-ve-raporlar)
  - [Profil ve Oyunlaştırma](#profil-ve-oyunlaştırma)
- [Mimari ve Kullanılan Teknolojiler](#mimari-ve-kullanılan-teknolojiler)
- [Makine Öğrenmesi Modelleri](#makine-öğrenmesi-modelleri)
- [Proje Yapısı](#proje-yapısı)
- [Kurulum ve Başlatma](#kurulum-ve-başlatma)
- [Lisans](#lisans)

---

## Projenin Amacı

Projenin temel amacı, bireylerin kendi sağlık verilerinin farkında olmalarını sağlamak ve bu verileri proaktif bir şekilde yönetmelerine olanak tanımaktır. BodyEcho, teknoloji (mobil uygulama, bulut bilişim, yapay zeka) ile yönetim (sağlık yönetimi, kişisel veri yönetimi) alanlarını bir araya getirerek, kullanıcıların sağlıkları hakkında veriye dayalı kararlar almalarını teşvik eder.

---

## Temel Özellikler

- **Kişiselleştirilmiş Sağlık Profili:** Yaş, boy, kilo, cinsiyet gibi temel verilerle Vücut Kitle İndeksi (VKİ) otomatik olarak hesaplanır ve tüm analizler bu kişisel verilere göre özelleştirilir.
- **Akıllı Besin Takibi:** **FatSecret API** entegrasyonu sayesinde, on binlerce gıda arasından arama yaparak tüketilen besinlerin kalori ve makro değerleri (protein, karbonhidrat, yağ) kolayca kaydedilir.
- **ML Destekli Kapsamlı Risk Analizi:** Kullanıcının demografik bilgileri ve yaşam tarzı verileri kullanılarak 6 farklı kronik hastalık riski (Obezite, Diyabet, Yüksek Kolesterol, Yüksek Şeker, Kanser, Düşük Aktivite) analiz edilir ve sonuçlar net bir şekilde sunulur.
- **İnteraktif Raporlar ve Grafikler:** Kullanıcının zaman içindeki ilerlemesi (kilo değişimi, kalori alımı vb.) anlaşılır grafiklerle görselleştirilir.
- **Motivasyonel Oyunlaştırma:** Kullanıcıların hedeflerine ulaştıkça veya belirli görevleri tamamladıkça kazandıkları avatarlar ve rozetler ile sağlıklı alışkanlıklar edinmeleri eğlenceli hale getirilir.

---

## Uygulama Akışı ve Ekranlar

Kullanıcının uygulama içindeki yolculuğu, basit ve anlaşılır adımlarla tasarlanmıştır.

### Giriş ve Kayıt

- **Ne Yapar?** Yeni kullanıcılar e-posta ve şifre ile kayıt olur. Kayıt sırasında, ML modelleri için temel girdi teşkil edecek olan yaş, cinsiyet, boy, kilo gibi demografik bilgiler alınır.
- **Arka Plan:** Girilen bilgiler **Firebase Authentication** ile doğrulanır ve kullanıcı kimliği oluşturulur. Kullanıcının kişisel verileri, **Cloud Firestore** veritabanında kendine ait güvenli bir doküman içinde saklanır.

### Ana Panel (Dashboard)

- **Kullanıcı Ne Görür?** Uygulamaya giriş yapıldığında kullanıcıyı karşılayan ana ekrandır. Bu ekranda:
  - Günlük hedeflerin özet kartları (örn: "8 bardak sudan 2'si içildi", "2000 kaloriden 1200'ü alındı").
  - Günün motivasyonel sözü veya bir sağlık ipucu.
  - Veri girişi için hızlı erişim butonu (Floating Action Button).
  - Mevcut oyunlaştırma avatarı.
- **Nasıl Çalışır?** Ekran yüklendiğinde, Firestore'dan o güne ait veri kayıtları (su, kalori vb.) çekilir ve özet kartları bu verilere göre güncellenir.

### Veri Giriş Akışı (Besin, Su, Aktivite)

Bu akış, uygulamanın en sık kullanılan özelliğidir. Örnek olarak **besin ekleme** akışı:

1.  **Kullanıcı Ne Yapar?** Ana Panel'deki '+' butonuna basar ve "Besin Ekle" seçeneğini seçer.
2.  **Arayüz:** Kullanıcıya bir arama çubuğu sunulur. Kullanıcı, yediği yemeği yazar (örn: "Elma").
3.  **Arka Plan (API Çağrısı):**
    -   Flutter uygulaması, arama terimini (`"Elma"`) alarak backend'de bulunan **Google Cloud Function**'a bir HTTPS isteği gönderir.
    -   Python ile yazılmış bu fonksiyon, isteği alır ve **FatSecret API**'sine bu terimle bir sorgu gönderir.
    -   FatSecret API, "Elma" ile eşleşen gıdaların bir listesini (besin değerleriyle birlikte) döndürür.
    -   Cloud Function, bu listeyi işleyerek mobil uygulamanın anlayacağı bir JSON formatında geri gönderir.
4.  **Kullanıcı Ne Görür?** Arama sonuçları ekranda listelenir ("Orta Boy Elma", "Elma Suyu" vb.). Kullanıcı doğru olanı seçer ve miktarını belirtir.
5.  **Veri Kaydı:** Uygulama, seçilen besinin kalori ve makro değerlerini hesaplar ve bu kaydı kullanıcının o günkü öğünü olarak **Cloud Firestore**'a yazar. Ana Panel'deki kalori sayacı anında güncellenir.

### Sağlık Analizi ve Raporlar

- **Kullanıcı Ne Yapar?** Alt navigasyon menüsünden "Analiz" sekmesine geçer.
- **Arka Plan (ML Modeli Çağrısı):**
    1.  "Analiz" ekranı açıldığında, uygulama **Firestore**'dan kullanıcının profil bilgilerini (yaş, VKİ vb.) ve son dönemdeki aktivite/beslenme özetini toplar.
    2.  Bu veriler, tek bir JSON objesi olarak paketlenir ve `predictRisk` adlı **Google Cloud Function**'a gönderilir.
    3.  Python backend'i, isteği alır ve gelen veriyi `scaler`'lar ile ön işleme tabi tutar.
    4.  Ön işlenmiş veri, `functions/models/` dizinindeki 6 farklı `.joblib` modeline (diyabet, obezite vb.) tek tek girdi olarak verilir.
    5.  Her model bir risk olasılığı veya kategorisi (`"Düşük"`, `"Orta"`, `"Yüksek"`) çıktısı üretir.
    6.  Tüm modellerin sonuçları birleştirilerek (`{"diabetes_risk": "High", "obesity_risk": "Low", ...}`) mobil uygulamaya geri döndürülür.
- **Kullanıcı Ne Görür?**
  -   Her bir sağlık riski için ayrı bir kart veya gösterge (gauge).
  -   Her kartın üzerinde net bir sonuç yazar: **Diyabet Riski: YÜKSEK**.
  -   Sonuçlar renk kodludur (kırmızı: yüksek risk, yeşil: düşük risk).
  -   Kullanıcı bir risk kartına tıkladığında, bu sonuca etki eden ana faktörler hakkında basit açıklamalar görebilir (örn: "Yüksek VKİ ve düşük aktivite seviyeniz bu riski artırmaktadır.").

### Profil ve Oyunlaştırma

- **Kullanıcı Ne Görür?** Bu ekranda kişisel bilgilerini, hesap ayarlarını, bildirim tercihlerini ve oyunlaştırma ile ilgili ilerlemesini görür.
- **Nasıl Çalışır?**
  -   Kullanıcı, "7 gün boyunca her gün spor yapma" gibi bir hedefi tamamladığında, sistem bunu algılar.
  -   Firestore'daki kullanıcı profiline yeni bir rozet veya avatar (`iyi_spor.png`) eklenir.
  -   Kullanıcı bu ekrana girdiğinde, kazandığı yeni avatarları ve rozetleri görür ve bunları aktif avatarı olarak ayarlayabilir. Bu, kullanıcıyı motive eden bir geri bildirim döngüsü oluşturur.

---

## Mimari ve Kullanılan Teknolojiler

Proje, modern ve ölçeklenebilir bir mimari üzerine kurulmuştur.

- **Frontend (Mobil Uygulama):** **Flutter (Dart)** - Tek kod tabanı ile cross-platform (iOS/Android) geliştirme.
- **Backend (Sunucu Tarafı):** **Google Cloud Functions (Python)** - Makine öğrenmesi ve harici API çağrıları için serverless (sunucusuz) yapı.
- **Veritabanı:** **Cloud Firestore (NoSQL)** - Esnek, gerçek zamanlı ve ölçeklenebilir veri depolama.
- **Kimlik Doğrulama:** **Firebase Authentication** - Güvenli ve kolay kullanıcı yönetimi.
- **Harici API'ler:** **FatSecret API** - Kapsamlı besin veritabanı.
- **CI/CD:** **GitHub Actions** - Otomatik test ve dağıtım süreçleri.

---

## Makine Öğrenmesi Modelleri

- **Eğitim Süreci:** Modeller, `scikit-learn` ve `Pandas` kullanılarak `ml_assets/AKILLI.ipynb` Jupyter Notebook'unda geliştirilmiştir. Veri ön işleme adımlarında `StandardScaler` kullanılmış ve bu ölçekleyiciler de modellerle birlikte kaydedilmiştir.
- **Kullanılan Modeller:** `obesity_risk_model.joblib`, `diabetes_risk_model.joblib`, `high_cholesterol_risk_model.joblib`, `high_sugar_risk_model.joblib`, `cancer_risk_model.joblib`, `low_activity_risk_model.joblib`.

---

## Proje Yapısı

-   `lib/`: Flutter uygulamasının ana Dart kodları.
-   `functions/`: Google Cloud Functions üzerinde çalışan Python backend kodları ve ML modelleri.
-   `assets/`: Logo, JSON verileri, SVG ikonları gibi statik varlıklar.
-   `ml_assets/`: ML modelinin geliştirme sürecinde kullanılan Jupyter Notebook, ham veri seti vb.
-   `.github/workflows/`: CI/CD otomasyon dosyaları.

---

## Kurulum ve Başlatma

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

1.  **Ön Gereksinimler:** Flutter SDK, Firebase CLI, Python.
2.  **Projeyi Klonlayın:** `git clone https://github.com/kullanici/bodyecho.git`
3.  **Flutter Bağımlılıklarını Yükleyin:** `flutter pub get`
4.  **Firebase Yapılandırması:** Projenize özel `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını ekleyin ve `flutterfire configure` komutunu çalıştırın.
5.  **Backend Fonksiyonlarını Dağıtın:** `cd functions && firebase deploy --only functions`
6.  **Uygulamayı Çalıştırın:** `flutter run`

---

## Lisans

Bu proje, [MIT Lisansı](LICENSE) altında lisanslanmıştır.