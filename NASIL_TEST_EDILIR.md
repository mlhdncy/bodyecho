# 🧪 Oyunlaştırma Sistemi - Test Kılavuzu

## 📱 Rozetleri Görüntüleme

### Adım 1: Uygulamayı Başlat
```bash
flutter run
```

### Adım 2: Rozetleri Firestore'a Yükle (Sadece İlk Kez)

1. Uygulamada giriş yap
2. **Alt navigasyondan → Profil** sekmesine git
3. Sağ üstteki **düzenle (✏️)** ikonuna tıkla
4. Ayarlar sayfasının en altına scroll et
5. **"Rozetleri Yükle"** butonuna bas
6. Yeşil onay mesajını bekle: "✅ Rozetler başarıyla yüklendi!"

> ⚠️ **NOT:** Bu işlemi sadece bir kez yapın! Tekrar yaparsanız rozetler üzerine yazılır ama sorun olmaz.

### Adım 3: Rozetleri Gör

1. **Profil** sekmesine geri dön
2. Aşağı scroll et
3. **"Rozetler"** kartını gör:
   - Üstte: Kazanılan/Toplam sayı (örn: 0/30)
   - Progress bar
   - 4 sütunlu grid
   - Şu anda hepsi **gri/kilitli** olacak (henüz rozet kazanmadınız)

### Adım 4: Bir Rozete Tıkla

1. Herhangi bir rozete tıkla
2. Dialog açılır:
   - Rozet ikonu (emoji)
   - Rozet adı
   - Açıklama (nasıl kazanılır)
   - Tier göstergesi (Bronz/Gümüş/Altın/Platin)

## 🎮 İlk Rozeti Kazanma Testi

### Test 1: "İlk Adım" Rozetini Kazan (🚶)

1. **Ana Sayfa** → **Aktivite Ekle** butonuna bas
2. Herhangi bir aktivite ekle:
   - Tür: Yürüyüş
   - Süre: 30 dakika
   - Mesafe: 2 km
3. **Kaydet**
4. Console'da şunu göreceksin:
   ```
   Activity added! Points: 20, New badges: 1
   ```
5. **Profil** sekmesine git
6. **Rozetler** kartına bak:
   - "İlk Adım" 🚶 rozeti artık **renkli** olmalı
   - Sayı: 1/30

### Test 2: Puan Kazanma ve Seviye Görme

1. **Ana Sayfa** → AppBar'da **puan göstergesine** bak
   - Altın badge'de puan sayısını gör (örn: 20)
2. **Profil** →
   - Avatar etrafında progress bar
   - "LVL 1" badge
   - "20 Puan - Acemi" yazısı

### Test 3: Su Ekleme ve Puan Kazanma

1. **Ana Sayfa** → **Su Ekle** (0.25L) butonuna bas
2. 10 kez bas (toplam 2.5L = hedef tamamlandı)
3. Kazanacağın puanlar:
   - Her 0.25L için: 5 puan × 10 = 50 puan
   - Su hedefi tamamlama bonusu: 30 puan
   - **Toplam: 80 puan ekstra**
4. Profilde toplam puan: 100 olmalı

### Test 4: "Su İçici" Rozetini Kazanma (Uzun Test)

Bu rozet 7 gün üst üste su hedefini tamamlamak gerektirir.

**Hızlı Test için (Manuel Firestore):**
1. Firebase Console'a git
2. Firestore Database
3. `gamificationStats/{userId}` → `waterGoalDaysCount: 7` yap
4. Herhangi bir aksiyonu tekrar et (puan ver)
5. Rozet otomatik açılacak

## 🔥 Streak (Seri) Testi

### Streak Nasıl Çalışır?

- Her gün en az 1 aktivite yapman gerekir
- Aktiviteler: Su ekle, adım ekle, uyku ekle, aktivite ekle
- Ardışık günlerde aktivite = streak artar
- Bir gün boşluk = streak sıfırlanır

### Streak Test:

1. **Bugün:** Herhangi bir aktivite yap (su ekle)
   - Profilde: "🔥 1 Gün Serisi" görünecek
2. **Yarın:** Tekrar bir aktivite yap
   - "🔥 2 Gün Serisi"
3. **3. gün:** Tekrar aktivite
   - "🔥 3 Gün Serisi" + **"3 Gün Serisi" rozeti kazanılır!** + 50 bonus puan

## 📊 Rozet Listesi (Hızlı Referans)

### 🏃 Aktivite Rozetleri (Kolay Test)
- ✅ İlk Adım - İlk aktiviteyi ekle
- 🏃 5km Yürüyüşçü - Toplam 5km yap
- 📊 Başlangıç - 10 aktivite ekle

### 💧 Sağlık Rozetleri (Orta Test)
- 💧 Su İçici - 7 gün su hedefi
- 👟 Adım Atan - 7 gün adım hedefi
- 😴 İyi Uyuyan - 7 gün uyku hedefi

### 🔥 Streak Rozetleri (Kolay Test)
- 🔥 3 Gün Serisi - 3 gün üst üste aktif
- 🔥🔥 Bir Hafta Savaşçısı - 7 gün seri

### 🎯 Hedef Rozetleri
- ✅ İlk Hedef - Tüm günlük hedefleri 1 kez tamamla

## 🐛 Sorun Giderme

### Rozetler Görünmüyor?
1. Settings → "Rozetleri Yükle" butonuna tekrar bas
2. Firebase Console → `badgeDefinitions` koleksiyonunu kontrol et (30+ doküman olmalı)

### Puan Artmıyor?
1. Console loglarını kontrol et
2. Firebase Console → `users/{userId}` → `totalPoints` alanını kontrol et
3. Manuel olarak değer ekleyebilirsin

### Rozet Açılmıyor?
1. Firestore → `gamificationStats/{userId}` dokümanını kontrol et
2. İlgili sayaçları manuel artır (test için)
3. Herhangi bir aksiyonu tekrar et (badge check tetiklenir)

## 🎨 UI Görünüm Rehberi

### Ana Sayfa
```
┌─────────────────────────────┐
│  Merhaba, Melih       [⭐ 20]│ ← Puan göstergesi
├─────────────────────────────┤
│  [Avatar]                   │
│  [Progress Cards]           │
│  [Quick Actions]            │
└─────────────────────────────┘
```

### Profil Sayfası
```
┌─────────────────────────────┐
│  [◯ Progress Circle]        │ ← Seviye progress
│     [👤 Avatar]             │
│     [LVL 5]                 │ ← Seviye badge
│                             │
│  ⭐ 250 Puan - Sporcu       │ ← Puan ve başlık
│  🔥 15 Gün Serisi           │ ← Streak (varsa)
├─────────────────────────────┤
│  Fiziksel Bilgiler          │
├─────────────────────────────┤
│  Rozetler              5/30 │
│  ▓▓▓░░░░░░ 17%             │ ← Progress
│  ┌──┬──┬──┬──┐             │
│  │🚶│🏃│💧│🔥│             │ ← Rozet grid
│  ├──┼──┼──┼──┤             │
│  │📊│👟│😴│✅│             │
│  └──┴──┴──┴──┘             │
└─────────────────────────────┘
```

### Rozet Dialog
```
┌─────────────────────────┐
│    🎉 Kutlama           │
│                         │
│  Yeni Rozet Kazandın!   │
│                         │
│    ┌──────────┐         │
│    │    🏃    │ ← Büyük │
│    │  Renkli  │   ikon  │
│    └──────────┘         │
│    [  Altın  ] ← Tier   │
│                         │
│   5km Yürüyüşçü         │
│ Toplam 5km mesafe kat et│
│                         │
│   [   Harika!   ]       │
└─────────────────────────┘
```

## ✅ Test Checklist

- [ ] Rozetleri Firestore'a yükledim
- [ ] Profilde rozet galerisini gördüm
- [ ] İlk aktiviteyi ekledim
- [ ] "İlk Adım" rozetini kazandım
- [ ] Puan göstergesini gördüm (AppBar)
- [ ] Seviye badge'ini gördüm (Profil)
- [ ] Streak göstergesini gördüm
- [ ] Rozete tıklayıp detayları gördüm
- [ ] Su ekleme puanlarını aldım
- [ ] Günlük hedef bonusunu aldım

## 🚀 Hızlı Demo için Manuel Ayarlar

Firebase Console'dan hızlı test için:

```javascript
// users/{userId} - Seviye ve puanları manuel ayarla
{
  "totalPoints": 2500,  // Seviye 6 olur (Sporcu)
  "currentStreak": 15,
  "longestStreak": 20,
  "unlockedBadges": ["first_step", "5km_walker", "water_drinker"]
}

// gamificationStats/{userId} - İstatistikleri ayarla
{
  "totalDistanceKm": 25,
  "totalActivities": 15,
  "waterGoalDaysCount": 10,
  "stepsGoalDaysCount": 5
}
```

Sonra uygulamayı yeniden başlat ve Profil'e git - rozetleri ve progress'i göreceksin!

---

**🎉 İyi testler! Sorularınız olursa sorabilirsiniz.**
