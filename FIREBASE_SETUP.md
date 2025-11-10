# Firebase Setup Guide for Body Echo

This guide will help you set up Firebase for the Body Echo iOS application.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `body-echo` (or your preferred name)
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

## Step 2: Add iOS App

1. In Firebase Console, click on the iOS icon
2. Register app with Bundle ID: `com.bodyecho.app`
3. Enter app nickname: "Body Echo iOS"
4. Download `GoogleService-Info.plist`
5. Place the file in `BodyEcho/Resources/` directory
6. **Important**: Add `GoogleService-Info.plist` to `.gitignore`

## Step 3: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable **Email/Password** provider:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

## Step 4: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Select **Start in production mode**
4. Choose a Cloud Firestore location (select closest to your users)
5. Click "Enable"

## Step 5: Set Up Firestore Collections

The app will automatically create collections when users start using it, but here's the structure:

### Collections Structure:

```
bodyecho (database)
├── users/
│   └── {userId}/
│       ├── anonymousId: string
│       ├── fullName: string
│       ├── email: string (anonymized)
│       ├── level: number
│       ├── points: number
│       ├── avatarType: string
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── dailyMetrics/
│   └── {metricId}/
│       ├── userId: string (anonymous)
│       ├── date: timestamp
│       ├── steps: number
│       ├── waterIntake: number
│       ├── calorieEstimate: number
│       ├── sleepQuality: number
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── activities/
│   └── {activityId}/
│       ├── userId: string (anonymous)
│       ├── type: string
│       ├── duration: number
│       ├── distance: number
│       ├── caloriesBurned: number
│       ├── date: timestamp
│       └── createdAt: timestamp
│
└── healthTrends/
    └── {trendId}/
        ├── userId: string (anonymous)
        ├── date: timestamp
        ├── physicalActivity: number
        ├── sleepDuration: number
        ├── nutritionQuality: number
        └── createdAt: timestamp
```

## Step 6: Configure Firestore Security Rules

1. In Firestore Database, go to **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check authentication
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }

    // Daily metrics - authenticated users can read/write
    match /dailyMetrics/{metricId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated()
        && resource.data.userId == request.auth.uid;
    }

    // Activities - authenticated users can read/write
    match /activities/{activityId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated()
        && resource.data.userId == request.auth.uid;
    }

    // Health trends - authenticated users can read/write
    match /healthTrends/{trendId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated()
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click "Publish"

## Step 7: Enable Firebase Storage (Optional)

If you plan to allow users to upload profile pictures or other media:

1. In Firebase Console, go to **Storage**
2. Click "Get started"
3. Choose **Start in production mode**
4. Click "Done"
5. Set up Storage Security Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 8: Enable Firebase Analytics (Optional)

1. In Firebase Console, go to **Analytics**
2. Follow the setup wizard
3. Analytics events will be automatically collected

## Step 9: Create Indexes (Important!)

For better query performance, create composite indexes:

1. Go to **Firestore Database** > **Indexes** tab
2. Add the following indexes:

### Index 1: Daily Metrics by User and Date
- Collection: `dailyMetrics`
- Fields:
  - `userId` (Ascending)
  - `date` (Descending)

### Index 2: Activities by User and Date
- Collection: `activities`
- Fields:
  - `userId` (Ascending)
  - `date` (Descending)

### Index 3: Health Trends by User and Date
- Collection: `healthTrends`
- Fields:
  - `userId` (Ascending)
  - `date` (Ascending)

**Note**: You can also wait for the app to make queries and Firebase will prompt you to create indexes automatically.

## Step 10: Test Your Setup

1. Run the app in Xcode simulator or build via Codemagic
2. Create a test account
3. Verify in Firebase Console:
   - Check **Authentication** > **Users** for the new user
   - Check **Firestore Database** for created documents
4. Try logging in with the test account

## Firebase App ID Configuration

For Codemagic integration, you'll need your Firebase App ID:

1. In Firebase Console, go to **Project Settings**
2. Scroll down to "Your apps"
3. Find your iOS app
4. Copy the **App ID** (format: `1:1234567890:ios:abcdef...`)
5. Update `codemagic.yaml`:
   ```yaml
   firebase:
     ios:
       app_id: YOUR_FIREBASE_IOS_APP_ID  # Paste here
   ```

## Environment Variables for Codemagic

If you need Firebase CI token for automated deployments:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Generate CI token
firebase login:ci

# Copy the token and add to Codemagic environment variables
# Variable name: FIREBASE_TOKEN
```

## Monitoring & Analytics

### Set Up Crashlytics (Optional)

1. In Firebase Console, go to **Crashlytics**
2. Follow setup instructions
3. Add Crashlytics SDK to your app

### Monitor Usage

- **Authentication**: Track sign-ups and sign-ins
- **Firestore**: Monitor read/write operations
- **Analytics**: Track user engagement

## Cost Management

Firebase offers a generous free tier, but here are tips to manage costs:

1. **Firestore**:
   - Free: 50,000 reads/day, 20,000 writes/day
   - Use caching to reduce reads
   - Batch writes when possible

2. **Authentication**:
   - Free for email/password auth
   - Phone auth has limits

3. **Storage**:
   - Free: 5 GB storage, 1 GB/day downloads
   - Compress images before upload

4. **Set up Budget Alerts**:
   - Go to Google Cloud Console
   - Set up billing alerts

## Troubleshooting

### Common Issues:

**1. "GoogleService-Info.plist not found"**
- Ensure the file is in `BodyEcho/Resources/`
- Check if it's added to the Xcode target

**2. "Permission denied" errors**
- Check Firestore security rules
- Ensure user is authenticated

**3. "Index required" errors**
- Create the required index (Firebase will provide a link)
- Wait 2-3 minutes for index to build

**4. Authentication errors**
- Verify Email/Password provider is enabled
- Check if bundle ID matches in Firebase

## Security Best Practices

1. **Never commit GoogleService-Info.plist to git**
2. Use environment variables for sensitive data
3. Implement proper security rules
4. Regularly audit access logs
5. Enable App Check to prevent abuse
6. Use reCAPTCHA for authentication

## Support

For Firebase-specific issues:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Support](https://firebase.google.com/support)
- [StackOverflow: firebase](https://stackoverflow.com/questions/tagged/firebase)

---

**Your Firebase project is now ready for Body Echo!** 🎉
