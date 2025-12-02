#!/usr/bin/env python3
"""
Test script for FatSecret API with OAuth 1.0
This tests the same OAuth 1.0 flow used in Cloud Functions
"""

import requests
from requests_oauthlib import OAuth1

# FatSecret API Credentials (OAuth 1.0)
CONSUMER_KEY = 'f7a036bce03d407082f0051ed0c8639a'
CONSUMER_SECRET = '7d39bab75a9746b58742a7fc080062a0'


def test_oauth1_search():
    """Test FatSecret food search with OAuth 1.0"""
    print("=" * 60)
    print("Testing FatSecret API with OAuth 1.0")
    print("=" * 60)

    try:
        # Create OAuth1 authentication
        auth = OAuth1(
            CONSUMER_KEY,
            CONSUMER_SECRET,
            signature_method='HMAC-SHA1',
            signature_type='AUTH_HEADER'
        )

        # FatSecret REST API endpoint
        url = 'https://platform.fatsecret.com/rest/server.api'

        # Search parameters
        params = {
            'method': 'foods.search',
            'search_expression': 'apple',
            'format': 'json',
            'max_results': '5'
        }

        print(f"\n1. Making API request to: {url}")
        print(f"   Search query: 'apple'")
        print(f"   OAuth 1.0 Signature Method: HMAC-SHA1")

        # Make the request
        response = requests.post(url, data=params, auth=auth, timeout=30)

        print(f"\n2. Response Status Code: {response.status_code}")
        print(f"   Response Headers: {dict(response.headers)}")

        # Check response
        if response.status_code == 200:
            print("\n[SUCCESS] OAuth 1.0 authentication worked!")

            data = response.json()
            print(f"\n3. Response Data:")

            if 'foods' in data and 'food' in data['foods']:
                foods = data['foods']['food']
                food_list = foods if isinstance(foods, list) else [foods]

                print(f"   Found {len(food_list)} food items:")
                for i, food in enumerate(food_list[:3], 1):
                    print(f"\n   Food #{i}:")
                    print(f"   - ID: {food.get('food_id')}")
                    print(f"   - Name: {food.get('food_name')}")
                    print(f"   - Type: {food.get('food_type')}")
                    desc = food.get('food_description', '')
                    if desc:
                        print(f"   - Description: {desc[:100]}...")
            else:
                print("   No food items found in response")
                print(f"   Raw response: {response.text[:500]}")

        elif response.status_code == 401:
            print("\n[ERROR] AUTHENTICATION FAILED!")
            print("   Status: 401 Unauthorized")
            print("   This means OAuth 1.0 credentials are invalid or signature is incorrect")
            print(f"   Response: {response.text}")

        elif response.status_code == 403:
            print("\n[ERROR] ACCESS FORBIDDEN!")
            print("   Status: 403 Forbidden")
            print("   Check API permissions or rate limits")
            print(f"   Response: {response.text}")

        else:
            print(f"\n[ERROR] REQUEST FAILED!")
            print(f"   Status: {response.status_code}")
            print(f"   Response: {response.text[:500]}")

    except requests.exceptions.Timeout:
        print("\n[ERROR] REQUEST TIMEOUT!")
        print("   The API took too long to respond")

    except requests.exceptions.ConnectionError as e:
        print("\n[ERROR] CONNECTION ERROR!")
        print(f"   Unable to reach FatSecret API: {e}")

    except Exception as e:
        print(f"\n[ERROR] UNEXPECTED ERROR!")
        print(f"   Error: {e}")
        import traceback
        traceback.print_exc()

    print("\n" + "=" * 60)


if __name__ == "__main__":
    test_oauth1_search()
