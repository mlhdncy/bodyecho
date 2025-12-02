import requests
import json
import base64

CLIENT_ID = 'f7a036bce03d407082f0051ed0c8639a'
CLIENT_SECRET = '7d1ca9b45a964c3095f04a0cdec04ee3'

def test_fatsecret():
    print("Testing FatSecret API...")
    
    # 1. Get Token
    token_url = 'https://oauth.fatsecret.com/connect/token'
    auth = requests.auth.HTTPBasicAuth(CLIENT_ID, CLIENT_SECRET)
    data = {'grant_type': 'client_credentials', 'scope': 'basic'}
    
    print(f"Requesting token from {token_url}...")
    try:
        response = requests.post(token_url, data=data, auth=auth)
        print(f"Token Response Status: {response.status_code}")
        print(f"Token Response Body: {response.text}")
        
        if response.status_code != 200:
            print("Failed to get token.")
            return

        token = response.json()['access_token']
        print("Token obtained successfully.")
        
        # 2. Search Food
        search_url = 'https://platform.fatsecret.com/rest/server.api'
        params = {
            'method': 'foods.search',
            'search_expression': 'apple',
            'format': 'json'
        }
        headers = {'Authorization': f'Bearer {token}'}
        
        print(f"Searching for 'apple' at {search_url}...")
        response = requests.get(search_url, params=params, headers=headers)
        print(f"Search Response Status: {response.status_code}")
        print(f"Search Response Body: {response.text[:500]}")
        
    except Exception as e:
        print(f"Exception: {e}")

if __name__ == "__main__":
    test_fatsecret()
