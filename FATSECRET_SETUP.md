# FatSecret API Entegrasyonu - Kurulum ve Kullanım

## 📋 Genel Bakış

Bu proje, kalori hesaplaması için FatSecret API'ını OAuth 1.0 kullanarak entegre etmiştir.

### Teknolojiler
- **Backend**: Firebase Cloud Functions (Python)
- **OAuth**: OAuth 1.0 (HMAC-SHA1 signature)
- **Frontend**: Flutter (Dart)
- **API**: FatSecret Platform API

## 🔑 API Credentials Kurulumu

### 1. FatSecret API Key Alma
1. [FatSecret Platform](https://platform.fatsecret.com/) adresine gidin
2. Hesap oluşturun veya giriş yapın
3. "My Applications" bölümünden yeni bir uygulama oluşturun
4. Consumer Key ve Consumer Secret'ı not alın

### 2. Environment Variables Yapılandırması

#### Cloud Functions (Backend)
`functions/.env` dosyası oluşturun:

```env
# FatSecret API Credentials (OAuth 1.0)
FATSECRET_CONSUMER_KEY=your_consumer_key_here
FATSECRET_CONSUMER_SECRET=your_consumer_secret_here
```

**ÖNEMLİ**: `.env` dosyası `.gitignore`'a eklenmiştir ve Git'e commit edilmeyecektir.

#### Firebase Functions Config (Production)
Production ortamında environment variables'ları Firebase'e ekleyin:

```bash
firebase functions:config:set fatsecret.consumer_key="your_consumer_key"
firebase functions:config:set fatsecret.consumer_secret="your_consumer_secret"
```

## 🏗️ Mimari

### Backend (Cloud Functions)

**Dosya**: `functions/main.py`

```
search_food()
├── OAuth 1.0 Authentication (HMAC-SHA1)
├── FatSecret API Request (POST)
├── Error Handling (401, 403, 429, 500)
└── Response Formatting
```

**Endpoint**: `https://search-food-xxuiubzqna-uc.a.run.app`

**Features**:
- ✅ OAuth 1.0 ile güvenli authentication
- ✅ Environment variables ile credential management
- ✅ Comprehensive error handling
- ✅ CORS support
- ✅ 60 saniye timeout
- ✅ Detaylı logging

### Frontend (Flutter)

**Dosya**: `lib/services/nutrition_service.dart`

```
NutritionService.searchFoods()
├── HTTP POST to Cloud Function
├── Retry Mechanism (3 attempts, 2s delay)
├── Timeout (30 seconds)
├── Response Parsing
│   ├── Calories extraction (multiple regex patterns)
│   ├── Unit extraction
│   └── Category mapping
└── Error Handling
```

**Features**:
- ✅ Automatic retry (3 attempts)
- ✅ 30 saniye timeout
- ✅ Robust parsing (multiple regex patterns)
- ✅ Error handling per status code
- ✅ Turkish category mapping

## 🧪 Test Etme

### Test Scripti (OAuth 1.0)
```bash
python test_oauth1.py
```

Bu script:
- OAuth 1.0 authentication test eder
- "apple" araması yapar
- Response'u parse eder
- Detaylı debug bilgisi verir

### Manuel Test (cURL)
```bash
curl -X POST https://search-food-xxuiubzqna-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{"query": "apple"}'
```

## 📝 API Response Format

### Cloud Function Response (Success)
```json
{
  "success": true,
  "data": {
    "foods": {
      "food": [
        {
          "food_id": "12345",
          "food_name": "Apple",
          "food_type": "Generic",
          "food_description": "Per 100g - Calories: 52kcal | Fat: 0.17g | Carbs: 13.81g | Protein: 0.26g"
        }
      ]
    }
  }
}
```

### Cloud Function Response (Error)
```json
{
  "success": false,
  "error": "Authentication failed - Invalid API credentials",
  "error_code": "AUTH_FAILED",
  "details": "..."
}
```

## 🔧 Deployment

### 1. Dependencies Yükleme
```bash
cd functions
pip install -r requirements.txt
```

### 2. Environment Variables Ayarlama
`.env` dosyasını oluşturun ve credentials'ları ekleyin (yukarıya bakın).

### 3. Firebase'e Deploy
```bash
firebase deploy --only functions:search_food
```

### 4. Flutter Dependencies
```bash
flutter pub get
```

## ⚠️ Önemli Notlar

### OAuth 1.0 vs OAuth 2.0
- **Cloud Function**: OAuth 1.0 kullanır (HMAC-SHA1 signature)
- **Test dosyaları**: `test_fatsecret.py` ve `test_fatsecret.js` OAuth 2.0 kullanır
- Bu normal! FatSecret her iki yöntemi de destekler
- Production'da OAuth 1.0 kullanıyoruz çünkü server-side daha güvenli

### Rate Limits
- FatSecret API rate limit'leri vardır
- 429 (Too Many Requests) hatası alırsanız beklemeniz gerekir
- Cloud Function ve Flutter otomatik retry yapar

### Güvenlik
- ❌ API credentials'ları ASLA code'a hardcode etmeyin
- ✅ Her zaman environment variables kullanın
- ✅ `.env` dosyası `.gitignore`'da olmalı
- ✅ Production'da Firebase Functions Config kullanın

## 🐛 Troubleshooting

### Problem: "Authentication failed" (401)
**Çözüm**:
- API credentials'ları kontrol edin
- `.env` dosyasının doğru konumda olduğundan emin olun
- Environment variables'ın yüklendiğini kontrol edin

### Problem: "Rate limit exceeded" (429)
**Çözüm**:
- Biraz bekleyin (5-10 dakika)
- Request sayısını azaltın
- Caching mechanism ekleyin

### Problem: "Request timeout"
**Çözüm**:
- İnternet bağlantınızı kontrol edin
- FatSecret API'nin erişilebilir olduğunu kontrol edin
- Timeout süresini artırın (Cloud Function'da `timeout_sec` parametresi)

### Problem: "No food items found"
**Çözüm**:
- Arama query'sini kontrol edin
- FatSecret API'de o yiyecek olmayabilir
- Response format'ını kontrol edin (logging açık)

## 📚 Kaynaklar

- [FatSecret Platform API Documentation](https://platform.fatsecret.com/api/)
- [OAuth 1.0 Specification](https://oauth.net/core/1.0/)
- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)

## 🔄 Güncellemeler

### v2.0 (2025-12-02)
- ✅ OAuth 1.0 implementation düzeltildi
- ✅ Environment variables ile credential management
- ✅ Comprehensive error handling (Cloud Function)
- ✅ Retry mechanism (Flutter)
- ✅ Improved response parsing
- ✅ Better timeout handling
- ✅ Detailed logging

### v1.0 (Initial)
- OAuth 1.0 implementasyonu (bazı hatalarla)
- Hardcoded credentials
- Temel error handling
