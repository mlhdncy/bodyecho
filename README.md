# Body Echo -  Health & Wellness App

Body Echo is a comprehensive health and wellness flutter application that helps users track their daily activities, monitor health metrics, and receive AI-powered insights for better health management.

## Features

- **User Authentication**: Secure email/password authentication with Firebase
- **Daily Health Tracking**:
  - Step counting
  - Water intake monitoring
  - Calorie estimation
  - Sleep quality tracking
- **Activity Logging**: Track walking, running, and cycling activities
- **Health Trends**: Visualize health metrics over time
- **AI-Powered Insights**: Receive personalized health recommendations
- **Level & Points System**: Gamification to encourage healthy habits
- **Data Privacy**: All user data is anonymized for privacy

## Tech Stack

- **Platform**: iOS 16+
- **UI Framework**: SwiftUI
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Firebase Analytics
- **Architecture**: MVVM (Model-View-ViewModel)
- **CI/CD**: Codemagic
- **Dependency Manager**: Swift Package Manager

## Project Structure

```
BodyEcho/
├── BodyEcho/
│   ├── BodyEchoApp.swift          # App entry point
│   ├── ContentView.swift           # Root view
│   ├── MainTabView.swift           # Main tab navigation
│   ├── Core/
│   │   ├── Authentication/         # Login & Registration
│   │   ├── Home/                   # Home screen & daily metrics
│   │   ├── Trends/                 # Health trends & insights
│   │   ├── ActivityLog/            # Activity logging
│   │   └── Profile/                # User profile & settings
│   ├── Models/                     # Data models
│   │   ├── User.swift
│   │   ├── DailyMetric.swift
│   │   ├── Activity.swift
│   │   └── HealthTrend.swift
│   ├── Services/                   # Business logic
│   │   ├── FirebaseService.swift
│   │   ├── AuthService.swift
│   │   └── AnonymizationService.swift
│   ├── Components/                 # Reusable UI components
│   │   ├── CustomButton.swift
│   │   ├── CustomTextField.swift
│   │   ├── CircularProgressView.swift
│   │   ├── ProgressBarView.swift
│   │   └── AvatarView.swift
│   ├── Utilities/                  # Helpers & extensions
│   │   ├── Extensions/
│   │   │   ├── Color+Theme.swift
│   │   │   └── View+Extensions.swift
│   │   └── Constants.swift
│   └── Resources/                  # Assets & resources
├── Package.swift                   # SPM dependencies
├── codemagic.yaml                  # CI/CD configuration
└── README.md
```

## Setup Instructions

### Prerequisites

- Firebase account
- Apple Developer account (for deployment)

### Firebase Setup

1. **Create a Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one
   - Add an iOS app to your project

2. **Download GoogleService-Info.plist**:
   - In Firebase Console, go to Project Settings
   - Download `GoogleService-Info.plist`
   - Place it in `BodyEcho/Resources/` directory

3. **Enable Firebase Services**:
   - **Authentication**: Enable Email/Password provider
   - **Firestore Database**: Create database in production mode
   - **Storage**: Enable Firebase Storage

4. **Firestore Security Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Daily metrics
    match /dailyMetrics/{metricId} {
      allow read, write: if request.auth != null;
    }

    // Activities
    match /activities/{activityId} {
      allow read, write: if request.auth != null;
    }

    // Health trends
    match /healthTrends/{trendId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Local Development Setup

Since you're developing on Windows and building with Codemagic:

1. **Clone the repository**:
```bash
git clone <your-repo-url>
cd bodyecho
```

2. **Install dependencies**:
   - Dependencies will be automatically resolved by Xcode when building
   - Firebase SDK is managed via Swift Package Manager

3. **Add GoogleService-Info.plist**:
   - Place your `GoogleService-Info.plist` in `BodyEcho/Resources/`
   - Make sure it's added to .gitignore

4. **Commit and push**:
```bash
git add .
git commit -m "Initial commit"
git push origin main
```

### Codemagic Setup

1. **Connect Repository**:
   - Go to [Codemagic](https://codemagic.io/)
   - Connect your Git repository

2. **Configure App**:
   - Select `codemagic.yaml` as configuration source
   - Add environment variables:
     - `FIREBASE_TOKEN`: Firebase CI token (optional)
     - `APP_STORE_APPLE_ID`: Your App Store Connect Apple ID

3. **Code Signing**:
   - Upload provisioning profiles
   - Upload distribution certificate
   - Or use Codemagic automatic signing

4. **Update codemagic.yaml**:
   - Replace `YOUR_FIREBASE_IOS_APP_ID` with actual Firebase App ID
   - Update `user@example.com` with your email
   - Adjust `BUNDLE_ID` if needed

5. **Start Build**:
   - Push to main branch to trigger build
   - Or manually start build in Codemagic dashboard

## Brand Colors

The app uses a calming teal/turquoise color palette:

- **Primary**: `#4CC9B0`, `#6ED1C8` (Teal/Turquoise)
- **Secondary**: `#A7D7C5`, `#B8E1DD`
- **Background**: `#F5F7FA`
- **Buttons**: `#2E9E9A`, `#247A76`
- **Alerts**: `#F66A4B`, `#FF9F68`
- **Avatar/Positive**: `#FADADD`, `#F6C6C6`

## Key Screens

### 1. Authentication
- Login screen with email/password
- Registration screen with terms acceptance
- Password reset (TODO)

### 2. Home Screen
- User greeting with avatar
- Daily motivation message
- Daily goals widget (steps, water, calories, sleep)
- AI-powered health insights
- Quick access to activity logging

### 3. Trends Screen
- Health metrics visualization
- Physical activity trends
- Sleep duration analysis
- Nutrition quality tracking

### 4. Activity Log Screen
- Tab-based interface (Nutrition, Activity, Sleep, Mood)
- Activity type selection (Walking, Running, Cycling)
- Duration and distance input
- Calorie calculation

### 5. Profile & Settings
- User profile information
- Level and points display
- App settings
- Privacy settings
- Sign out

## Data Privacy

Body Echo takes user privacy seriously:

- All user data is **anonymized** using SHA-256 hashing
- Email addresses are partially masked
- Firebase UIDs are converted to anonymous IDs
- No personally identifiable information is stored in plain text
- Users have full control over their data

## Future Enhancements

- [ ] Push notifications for daily reminders
- [ ] Apple Watch integration
- [ ] HealthKit integration for automatic data sync
- [ ] Social features (share achievements)
- [ ] More detailed nutrition tracking
- [ ] Meditation and breathing exercises
- [ ] Advanced AI insights and recommendations
- [ ] Dark mode support
- [ ] Multiple language support

## Testing

### Running Tests

Tests can be run using Xcode or Codemagic:

```bash
# Run unit tests (in Xcode)
xcodebuild test -scheme BodyEcho -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage

- Unit tests for Models
- Unit tests for Services
- UI tests for critical flows (TODO)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is proprietary and confidential.

## Support

For support, email support@bodyecho.app or open an issue in the repository.

---

**Built with ❤️ for health and wellness**
