import json
import os
import joblib
import pandas as pd
import numpy as np
import requests
from requests_oauthlib import OAuth1
from firebase_functions import https_fn
from firebase_admin import initialize_app
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

initialize_app()

# Load models and scalers globally to cache them between requests
MODELS = {}
SCALERS = {}
MODEL_FILES = {
    'diabetes_risk': 'diabetes_risk_model.joblib',
    'high_sugar_risk': 'high_sugar_risk_model.joblib',
    'obesity_risk': 'obesity_risk_model.joblib',
    'cancer_risk': 'cancer_risk_model.joblib',
    'low_activity_risk': 'low_activity_risk_model.joblib',
    'high_cholesterol_risk': 'high_cholesterol_risk_model.joblib'
}
SCALER_FILES = {
    'diabetes_risk': 'scaler_for_diabetes_risk_model.joblib',
    'high_sugar_risk': 'scaler_for_high_sugar_risk_model.joblib',
    'obesity_risk': 'scaler_for_obesity_risk_model.joblib',
    'cancer_risk': 'scaler_for_cancer_risk_model.joblib',
    'low_activity_risk': 'scaler_for_low_activity_risk_model.joblib',
    'high_cholesterol_risk': 'scaler_for_high_cholesterol_risk_model.joblib'
}

# Features to drop for each model (from akilli.py)
DROPPED_FEATURES = {
    'diabetes_risk': [],
    'high_sugar_risk': ['blood_glucose_level', 'diabetes'],
    'obesity_risk': ['bmi'],
    'cancer_risk': [],
    'low_activity_risk': ['active'],
    'high_cholesterol_risk': ['Cholesterolmg']
}

# Columns to scale (Original list from akilli.py, mapped to CSV names)
# COLS_TO_SCALE_ORIGINAL = ['age', 'bmi', 'blood_glucose_level', 'Calories_kcal', 'Sodium_mg', 'Cholesterol_mg', 'Water_Intake_ml', 'active', 'diabetes']
# Mapped to feature_importances names:
COLS_TO_SCALE = ['age', 'bmi', 'blood_glucose_level', 'Calorieskcal', 'Sodiummg', 'Cholesterolmg', 'Water_Intakeml', 'active', 'diabetes']

# Full list of columns expected by the models (derived from feature_importances.csv)
# We will fill missing ones with 0
EXPECTED_COLUMNS = [
    'blood_glucose_level', 'age', 'bmi', 'Calorieskcal', 'Water_Intakeml', 'Sodiummg', 'Cholesterolmg',
    'High_Sugar_Risk', 'Obesity_Risk', 'gender_Male', 'smoking_history_never', 'smoking_history_former',
    'Meal_Type_Lunch', 'Meal_Type_Dinner', 'Meal_Type_Snack', 'High_Cholesterol_Risk', 'Cancer_Risk_Score',
    'Category_Dairy', 'Category_Vegetables', 'Category_Grains', 'active', 'Category_Snacks', 'Low_Activity_Score',
    'Category_Fruits', 'Category_Meat', 'smoking_history_current', 'smoking_history_notcurrent', 'smoking_history_ever',
    'diabetes' # Target for some, feature for others? 'diabetes' is in COLS_TO_SCALE but usually target. 
               # In akilli.py, 'diabetes' is dropped for high_sugar_risk. 
               # But for diabetes_risk model, 'diabetes' is the target, so it shouldn't be in X.
               # However, if we are predicting diabetes, we don't have it.
               # Wait, akilli.py drops 'diabetes' in columns_to_drop_initial? 
               # No, columns_to_drop_initial = ['bmi.1', ... 'diabetes.1']. 'diabetes' stays.
               # But when training diabetes_risk, y='diabetes', so X drops 'diabetes'.
               # So 'diabetes' column should NOT be in the input for diabetes_risk model.
               # But it might be in input for others?
               # Model 2 (High Sugar) drops 'diabetes'.
               # It seems 'diabetes' is never used as a feature for the prediction models we care about.
               # So we can ignore it or set to 0.
]

def load_resources():
    model_dir = os.path.join(os.path.dirname(__file__), 'models')
    for key, filename in MODEL_FILES.items():
        if key not in MODELS:
            try:
                MODELS[key] = joblib.load(os.path.join(model_dir, filename))
                print(f"Loaded model: {key}")
            except Exception as e:
                print(f"Error loading model {key}: {e}")

    for key, filename in SCALER_FILES.items():
        if key not in SCALERS:
            try:
                SCALERS[key] = joblib.load(os.path.join(model_dir, filename))
                print(f"Loaded scaler: {key}")
            except Exception as e:
                print(f"Error loading scaler {key}: {e}")

@https_fn.on_request(min_instances=0, max_instances=1, memory=512)
def predict(req: https_fn.Request) -> https_fn.Response:
    load_resources()
    
    try:
        data = req.get_json()
        
        # 1. Prepare Base DataFrame
        input_data = {
            'age': [float(data.get('age', 30))],
            'bmi': [float(data.get('bmi', 25.0))],
            'blood_glucose_level': [float(data.get('blood_glucose_level', 100))],
            'active': [int(data.get('active', 0))],
            'Calorieskcal': [float(data.get('Calories_kcal', 2000))], # Mapped name
            'Sodiummg': [float(data.get('Sodium_mg', 2000))],       # Mapped name
            'Cholesterolmg': [float(data.get('Cholesterol_mg', 150))], # Mapped name
            'Water_Intakeml': [float(data.get('Water_Intake_ml', 2000))], # Mapped name
            # Categorical inputs
            'gender': data.get('gender', 'Female'),
            'smoking_history': data.get('smoking_history', 'never'),
            # Missing inputs that might be needed for logic
            'diabetes': [0] # Assume 0 for prediction
        }
        
        df = pd.DataFrame(input_data)
        
        # 2. Feature Engineering (Derived Features)
        # High Sugar Risk
        df['High_Sugar_Risk'] = np.where(df['blood_glucose_level'] >= 140, 1, 0)
        
        # Obesity Risk
        df['Obesity_Risk'] = np.where(df['bmi'] >= 30.0, 1, 0)
        
        # Cancer Risk Score
        # Map smoking history to columns first to check logic? 
        # Logic: is_smoker = (current == 1) | (former == 1)
        # We can do it on the raw string first
        is_smoker = df['smoking_history'].isin(['current', 'former'])
        is_obese = df['bmi'] >= 30
        df['Cancer_Risk_Score'] = np.where(is_smoker & is_obese, 1, 0)
        
        # Low Activity Score
        df['Low_Activity_Score'] = np.where(df['active'] == 0, 1, 0)
        
        # High Cholesterol Risk
        # Median assumption: 200 (approximate)
        cholesterol_threshold = 200 * 1.15
        df['High_Cholesterol_Risk'] = np.where(df['Cholesterolmg'] > cholesterol_threshold, 1, 0)

        # 3. One-Hot Encoding / Column Mapping
        # Initialize all expected columns with 0
        for col in EXPECTED_COLUMNS:
            if col not in df.columns:
                df[col] = 0
                
        # Set specific one-hot columns based on input
        if input_data['gender'] == 'Male':
            df['gender_Male'] = 1
            
        smoker_status = input_data['smoking_history']
        if smoker_status == 'never':
            df['smoking_history_never'] = 1
        elif smoker_status == 'former':
            df['smoking_history_former'] = 1
        elif smoker_status == 'current':
            df['smoking_history_current'] = 1
        elif smoker_status == 'not current': # Check exact string from app
            df['smoking_history_notcurrent'] = 1
        elif smoker_status == 'ever':
            df['smoking_history_ever'] = 1
            
        # 4. Prediction Loop
        results = {}
        
        for model_name in MODEL_FILES.keys():
            if model_name not in MODELS or model_name not in SCALERS:
                results[model_name] = {'error': 'Model not loaded'}
                continue
                
            model = MODELS[model_name]
            scaler = SCALERS[model_name]
            
            # Prepare X for this model
            # Start with full df
            X = df.copy()
            
            # Drop target/forbidden columns for this model
            drops = DROPPED_FEATURES.get(model_name, [])
            # Also drop 'diabetes' if it's in X and not needed (it's usually target)
            # For safety, drop 'diabetes' from all inputs as we are predicting risks
            if 'diabetes' in X.columns:
                X = X.drop('diabetes', axis=1)
                
            for col in drops:
                if col in X.columns:
                    X = X.drop(col, axis=1)
            
            # Ensure X has only the columns the model expects (and in correct order if possible)
            # The scaler expects specific columns.
            # We need to filter X to match what scaler expects + what model expects.
            # Actually, we should align X with EXPECTED_COLUMNS minus drops.
            # But scaler.transform needs specific columns.
            
            # Identify columns to scale that are present in X
            cols_to_scale_here = [c for c in COLS_TO_SCALE if c in X.columns]
            
            # Scale
            if cols_to_scale_here:
                X[cols_to_scale_here] = scaler.transform(X[cols_to_scale_here])
            
            # Reorder columns to match model's expectation? 
            # RandomForest matches by name if dataframe? No, usually by position.
            # We must ensure column order matches training.
            # We don't have the exact training column order easily available unless we saved it.
            # BUT, we have feature_importances.csv which lists them.
            # We should reindex X to match the feature_importances order (or the order in EXPECTED_COLUMNS if that was sorted).
            # Let's assume EXPECTED_COLUMNS contains all possible columns.
            # We need to intersect with X.columns and sort?
            # Ideally we should have saved X_train.columns.
            # Workaround: Use the keys from feature_importances.csv for that model to order columns.
            # But feature_importances might not include columns with 0 importance?
            # Usually it does.
            # Let's try to predict. If feature mismatch, it will error.
            
            # For now, we will try to pass X as is (Pandas DF). Sklearn recent versions are better at handling feature names.
            # If it fails, we catch exception.
            
            try:
                prediction = model.predict(X)[0]
                probability = model.predict_proba(X)[0][1] # Probability of class 1
                
                results[model_name] = {
                    'prediction': int(prediction),
                    'probability': float(probability),
                    'risk_level': 'High' if prediction == 1 else 'Low'
                }
            except Exception as e:
                results[model_name] = {'error': str(e)}

        return https_fn.Response(json.dumps({'success': True, 'results': results}), content_type='application/json')
        
    except Exception as e:
        return https_fn.Response(json.dumps({'success': False, 'error': str(e)}), status=500, content_type='application/json')

@https_fn.on_request(min_instances=0, max_instances=1, timeout_sec=60)
def search_food(req: https_fn.Request) -> https_fn.Response:
    # Enable CORS
    if req.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return https_fn.Response('', status=204, headers=headers)

    headers = {'Access-Control-Allow-Origin': '*'}

    try:
        # Parse request
        print(f"Request Headers: {req.headers}")
        print(f"Request Data: {req.get_data(as_text=True)}")

        req_json = req.get_json(silent=True)
        query = None

        if req_json and 'query' in req_json:
            query = req_json['query']
        elif req.args and 'query' in req.args:
            query = req.args['query']

        print(f"Search Food Request (OAuth1): query={query}")

        if not query:
            return https_fn.Response(
                json.dumps({
                    'success': False,
                    'error': 'Query parameter is required',
                    'error_code': 'MISSING_QUERY'
                }),
                status=400,
                headers=headers,
                content_type='application/json'
            )

        # FatSecret Credentials (OAuth 1.0) - Load from environment variables
        CONSUMER_KEY = os.getenv('FATSECRET_CONSUMER_KEY')
        CONSUMER_SECRET = os.getenv('FATSECRET_CONSUMER_SECRET')

        if not CONSUMER_KEY or not CONSUMER_SECRET:
            print("ERROR: FatSecret credentials not found in environment variables")
            return https_fn.Response(
                json.dumps({
                    'success': False,
                    'error': 'API credentials not configured',
                    'error_code': 'MISSING_CREDENTIALS'
                }),
                status=500,
                headers=headers,
                content_type='application/json'
            )

        # Create OAuth1 Session
        # FatSecret uses OAuth 1.0 with HMAC-SHA1 signature method
        # The requests_oauthlib library handles signature generation automatically
        auth = OAuth1(
            CONSUMER_KEY,
            CONSUMER_SECRET,
            signature_method='HMAC-SHA1',
            signature_type='AUTH_HEADER'
        )

        # Search Food using FatSecret REST API
        url = 'https://platform.fatsecret.com/rest/server.api'
        params = {
            'method': 'foods.search',
            'search_expression': query,
            'format': 'json',
            'max_results': '20'  # Limit results
        }

        print(f"Making FatSecret API request with params: {params}")

        # Use POST with timeout for better reliability
        search_resp = requests.post(
            url,
            data=params,
            auth=auth,
            timeout=30  # 30 second timeout
        )

        print(f"Search Response Status: {search_resp.status_code}")
        print(f"Search Response Headers: {search_resp.headers}")
        print(f"Search Response Body: {search_resp.text[:1000]}")

        # Handle different error codes
        if search_resp.status_code == 401:
            return https_fn.Response(
                json.dumps({
                    'success': False,
                    'error': 'Authentication failed - Invalid API credentials',
                    'error_code': 'AUTH_FAILED',
                    'details': search_resp.text
                }),
                status=401,
                headers=headers,
                content_type='application/json'
            )
        elif search_resp.status_code == 403:
            return https_fn.Response(
                json.dumps({
                    'success': False,
                    'error': 'Access forbidden - Check API permissions',
                    'error_code': 'FORBIDDEN',
                    'details': search_resp.text
                }),
                status=403,
                headers=headers,
                content_type='application/json'
            )
        elif search_resp.status_code == 429:
            return https_fn.Response(
                json.dumps({
                    'success': False,
                    'error': 'Rate limit exceeded - Too many requests',
                    'error_code': 'RATE_LIMIT',
                    'details': search_resp.text
                }),
                status=429,
                headers=headers,
                content_type='application/json'
            )
        elif search_resp.status_code != 200:
            return https_fn.Response(
                json.dumps({
                    'success': False,
                    'error': f'FatSecret API request failed with status {search_resp.status_code}',
                    'error_code': 'API_ERROR',
                    'details': search_resp.text
                }),
                status=500,
                headers=headers,
                content_type='application/json'
            )

        # Parse response
        try:
            response_data = search_resp.json()
            # Wrap response in success envelope
            return https_fn.Response(
                json.dumps({
                    'success': True,
                    'data': response_data
                }),
                headers=headers,
                content_type='application/json'
            )
        except json.JSONDecodeError as je:
            print(f"JSON Parse Error: {je}")
            return https_fn.Response(
                json.dumps({
                    'success': False,
                    'error': 'Failed to parse API response',
                    'error_code': 'PARSE_ERROR',
                    'details': str(je)
                }),
                status=500,
                headers=headers,
                content_type='application/json'
            )

    except requests.exceptions.Timeout:
        print("Request timeout")
        return https_fn.Response(
            json.dumps({
                'success': False,
                'error': 'Request timeout - FatSecret API took too long to respond',
                'error_code': 'TIMEOUT'
            }),
            status=504,
            headers=headers,
            content_type='application/json'
        )
    except requests.exceptions.ConnectionError as ce:
        print(f"Connection Error: {ce}")
        return https_fn.Response(
            json.dumps({
                'success': False,
                'error': 'Connection error - Unable to reach FatSecret API',
                'error_code': 'CONNECTION_ERROR',
                'details': str(ce)
            }),
            status=503,
            headers=headers,
            content_type='application/json'
        )
    except Exception as e:
        print(f"Unexpected Exception: {e}")
        import traceback
        traceback.print_exc()
        return https_fn.Response(
            json.dumps({
                'success': False,
                'error': f'Unexpected error: {str(e)}',
                'error_code': 'UNKNOWN_ERROR'
            }),
            status=500,
            headers=headers,
            content_type='application/json'
        )
