from flask import Flask, request, jsonify
import joblib
import pandas as pd
import numpy as np

app = Flask(__name__)

# Modelleri ve Scaler'ları Yükle
models = {}
scalers = {}

model_names = [
    'diabetes_risk',
    'high_sugar_risk',
    'obesity_risk',
    'cancer_risk',
    'low_activity_risk',
    'high_cholesterol_risk'
]

print("Modeller yükleniyor...")
for name in model_names:
    try:
        models[name] = joblib.load(f'{name}_model.joblib')
        scalers[name] = joblib.load(f'scaler_for_{name}_model.joblib')
        print(f"✅ {name} yüklendi.")
    except Exception as e:
        print(f"❌ {name} yüklenemedi: {e}")

# Özellik listesi (Eğitim sırasındaki sütun sırası önemli)
# Bu liste akilli.py'deki eğitim mantığına göre oluşturulmalıdır.
# Ancak her model farklı özellikler kullanmış olabilir (dropped_features nedeniyle).
# Bu yüzden her model için beklenen özellikleri tanımlamamız gerekebilir.
# Basitleştirmek için, gelen JSON verisini DataFrame'e çevirip,
# modelin beklediği sütunları seçip, eksikleri tamamlayacağız.

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        
        # Gelen veriyi DataFrame'e çevir
        # Beklenen giriş formatı:
        # {
        #   "gender": "Female",
        #   "age": 30,
        #   "hypertension": 0,
        #   "heart_disease": 0,
        #   "smoking_history": "never",
        #   "bmi": 25.5,
        #   "HbA1c_level": 5.5,
        #   "blood_glucose_level": 100,
        #   "Calories_kcal": 2000,
        #   "Sodium_mg": 2000,
        #   "Cholesterol_mg": 150,
        #   "Water_Intake_ml": 2000,
        #   "active": 1
        # }
        
        # Ön işleme (Preprocessing)
        # 1. Kategorik verileri (One-Hot Encoding) işle
        # Bu kısım biraz karmaşık çünkü eğitimdeki sütun yapısını birebir tutturmalıyız.
        # En güvenli yol: Eğitimdeki boş bir DataFrame yapısını şablon olarak kullanmak.
        
        # Şimdilik basit bir yaklaşım:
        # Kullanıcıdan ham veriyi alıp, eğitimdeki dönüşümleri burada tekrar uygulayacağız.
        
        input_df = pd.DataFrame([data])
        
        # One-Hot Encoding için manuel işlem veya pd.get_dummies
        # Ancak eğitim setindeki tüm olası sütunların burada da olması lazım.
        # Bu yüzden dummy bir eğitim satırı oluşturup onunla birleştirmek daha iyi olurdu.
        # Fakat elimizde eğitim verisi yok.
        # Bu nedenle, modelin beklediği özelliklerin (feature_names_in_) listesini kullanacağız.
        
        results = {}
        
        for name, model in models.items():
            if name not in scalers:
                continue
                
            scaler = scalers[name]
            
            # Modelin beklediği özellik isimleri
            expected_features = model.feature_names_in_
            
            # Gelen veriyi modelin beklediği formata uydur
            # 1. Eksik sütunları 0 ile doldur
            # 2. Fazla sütunları at
            # 3. Sıralamayı düzelt
            
            # Önce kategorik dönüşümleri yapalım (Basitçe)
            # Not: Bu kısım prodüksiyon için daha sağlam hale getirilmeli.
            # Örneğin 'gender' -> 'gender_Male', 'gender_Other' gibi.
            
            # Gelen veriyi işle
            processed_df = input_df.copy()
            
            # One-Hot Encoding (Basit manuel mapping - Eğitim verisine göre güncellenmeli)
            # Örnek: smoking_history
            smoking_status = data.get('smoking_history', 'never')
            processed_df[f'smoking_history_{smoking_status}'] = 1
            
            # Gender
            gender = data.get('gender', 'Female')
            processed_df[f'gender_{gender}'] = 1
            
            # Eksik sütunları 0 ile doldurarak oluştur
            model_input = pd.DataFrame(0, index=[0], columns=expected_features)
            
            for col in expected_features:
                if col in processed_df.columns:
                    model_input[col] = processed_df[col]
                elif col in input_df.columns:
                     model_input[col] = input_df[col]
            
            # Ölçekleme (Scaling)
            # Scaler'ın beklediği sütunları bul
            # Scaler feature names özelliği scikit-learn versiyonuna göre değişebilir.
            # Genelde scaler.feature_names_in_ kullanılır.
            
            if hasattr(scaler, 'feature_names_in_'):
                scale_cols = scaler.feature_names_in_
                model_input[scale_cols] = scaler.transform(model_input[scale_cols])
            
            # Tahmin
            prediction = model.predict(model_input)[0]
            probability = model.predict_proba(model_input)[0][1] # 1 sınıfının olasılığı
            
            results[name] = {
                'prediction': int(prediction),
                'probability': float(probability),
                'risk_level': 'High' if prediction == 1 else 'Low'
            }
            
        return jsonify({
            'success': True,
            'results': results
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
