# ML Modülü Dağıtım Kılavuzu

Firebase Cloud Functions kullanarak ML modellerinizi canlıya almak için aşağıdaki adımları izleyin.

## 1. Ön Hazırlıklar

1.  **Firebase CLI Yükleyin:**
    Eğer yüklü değilse:
    ```bash
    npm install -g firebase-tools
    ```

2.  **Firebase Gi    npm install -g firebase-tools
rişi Yapın:**
    ```bash
    firebase login
    ```

3.  **Projeyi Başlatın (Eğer yapılmadıysa):**
    ```bash
    firebase init functions
    ```
    *   Soru sorulduğunda **Python**'ı seçin.
    *   Mevcut `functions` klasörünü kullanmak isteyip istemediğiniz sorulursa **Hayır (No)** diyerek üzerine yazılmasını engelleyin veya dikkatli olun. Biz zaten dosyaları oluşturduk.

## 2. Dağıtım (Deploy)

Terminali açın ve proje ana dizininde şu komutu çalıştırın:

```bash
firebase deploy --only functions
```

Bu işlem birkaç dakika sürebilir. Başarılı olduğunda terminalde şöyle bir URL göreceksiniz:
`Function URL (predict): https://predict-xyz-uc.a.run.app`

## 3. Uygulamayı Güncelleme

1.  Yukarıdaki URL'i kopyalayın.
2.  `lib/services/ml_service.dart` dosyasını açın.
3.  `_baseUrl` değişkenini bu yeni URL ile güncelleyin:

```dart
static const String _baseUrl = 'https://predict-xyz-uc.a.run.app'; // Kendi URL'iniz
```

## Notlar
*   **Blaze Planı:** Cloud Functions kullanmak için Firebase projenizin "Blaze" (Kullandığın Kadar Öde) planında olması gerekir.
*   **Model Boyutları:** Eğer modelleriniz çok büyükse (toplam > 500MB), dağıtım sırasında hata alabilirsiniz. Bu durumda modelleri Firebase Storage'a yükleyip oradan çeken bir yapı kurmak gerekebilir.
