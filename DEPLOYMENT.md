# BodyEcho - GitHub Pages Deployment Kılavuzu

## Otomatik Deploy Kurulumu

Bu proje GitHub Actions kullanarak otomatik olarak GitHub Pages'e deploy edilmektedir.

### Adımlar:

1. **GitHub Repository Ayarları**
   - GitHub repository'nize gidin
   - Settings > Pages sekmesine tıklayın
   - Source kısmından "GitHub Actions" seçin

2. **Firebase Yapılandırması**

   GitHub Pages'te Firebase çalışması için Firebase projenizin public olarak erişilebilir olması gerekir. Eğer authentication kullanıyorsanız:

   - Firebase Console > Authentication > Settings > Authorized domains
   - GitHub Pages domain'inizi ekleyin: `[kullanıcı-adı].github.io`

3. **Environment Variables (Opsiyonel)**

   Eğer Firebase config bilgilerinizi gizli tutmak isterseniz:

   ```bash
   # Repository Settings > Secrets and variables > Actions
   # Aşağıdaki secret'ları ekleyin:
   FIREBASE_API_KEY
   FIREBASE_AUTH_DOMAIN
   FIREBASE_PROJECT_ID
   FIREBASE_STORAGE_BUCKET
   FIREBASE_MESSAGING_SENDER_ID
   FIREBASE_APP_ID
   ```

4. **Deploy**

   Main branch'e push yaptığınızda otomatik olarak deploy edilecektir:

   ```bash
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin main
   ```

5. **Deploy Durumunu Kontrol Etme**

   - Repository > Actions sekmesinde workflow'ların durumunu görebilirsiniz
   - Deploy tamamlandığında siteniz şu adreste yayında olacak:
     `https://[kullanıcı-adı].github.io/bodyecho/`

## Manuel Deploy (Opsiyonel)

Eğer manuel deploy etmek isterseniz:

```bash
# Web build oluştur
flutter build web --release --base-href /bodyecho/

# Build klasörünü gh-pages branch'ine push et
# (Bu adım için gh-pages ayrı bir branch olarak oluşturulmalı)
```

## Sorun Giderme

### 404 Hatası
- Base href'in doğru ayarlandığından emin olun: `/bodyecho/`
- Repository adınız farklıysa workflow dosyasındaki `--base-href` değerini güncelleyin

### Firebase Bağlantı Hatası
- Firebase config bilgilerinizin doğru olduğundan emin olun
- Firebase Console'da domain'in authorized olduğunu kontrol edin

### Build Hatası
- `flutter pub get` komutunu çalıştırın
- Flutter versiyonunuzun 3.24.0 veya üzeri olduğundan emin olun
- `flutter clean` ve tekrar build deneyin

## Güncelleme

Projeyi güncellemek için:

```bash
git add .
git commit -m "Update: [açıklama]"
git push origin main
```

GitHub Actions otomatik olarak yeni versiyonu deploy edecektir.

## Custom Domain (Opsiyonel)

Kendi domain'inizi kullanmak için:

1. Repository root'una `CNAME` dosyası ekleyin:
   ```
   yourdomain.com
   ```

2. DNS sağlayıcınızda A record ekleyin:
   ```
   185.199.108.153
   185.199.109.153
   185.199.110.153
   185.199.111.153
   ```

3. GitHub Settings > Pages > Custom domain kısmına domain'inizi ekleyin

## İletişim

Sorularınız için: [GitHub Issues](https://github.com/[kullanıcı-adı]/bodyecho/issues)
