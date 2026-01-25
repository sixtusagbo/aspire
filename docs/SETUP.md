# Manual Setup Guide

## 1. Firebase Project Setup

### Create Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it `aspire` (or `aspire-app` if taken)
4. Disable Google Analytics (optional, speeds up setup)
5. Click "Create project"

### Add Android App
1. In project overview, click the Android icon
2. Package name: `dev.sixtusagbo.aspire`
3. App nickname: `Aspire`
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`

### Enable Authentication
1. Go to Build > Authentication
2. Click "Get started"
3. Enable **Email/Password** provider
4. Enable **Google** provider:
   - Add support email
   - Note the Web Client ID (needed for Android)

### Configure Google Sign-In for Android
1. Go to Project Settings > Your apps > Android app
2. Add SHA-1 fingerprint:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy the SHA-1 from the debug variant
3. Download updated `google-services.json` and replace the old one

### Enable Firestore
1. Go to Build > Firestore Database
2. Click "Create database"
3. Start in **test mode** (we'll add rules later)
4. Choose nearest region (e.g., `us-central1`)

### Firestore Security Rules (for development)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 2. RevenueCat Setup

### Create Account
1. Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Sign up / Log in

### Create Project
1. Click "Create new project"
2. Name: `Aspire`

### Add Android App
1. In your project, go to Apps > Add app
2. Select **Google Play Store**
3. App name: `Aspire`
4. Package name: `dev.sixtusagbo.aspire`

### Get API Key
1. Go to your Android app in RevenueCat
2. Copy the **Public API Key** (starts with `goog_`)
3. You'll add this to the app later

### Create Products (Do after Google Play Console setup)
1. Go to Products > Entitlements
2. Create entitlement: `premium`
3. Go to Products > Products
4. Add products (after creating in Google Play Console):
   - `aspire_premium_monthly` ($4.99/month)
   - `aspire_premium_yearly` ($29.99/year)

### Create Offering
1. Go to Products > Offerings
2. Create offering: `default`
3. Add packages:
   - Monthly: attach `aspire_premium_monthly`
   - Annual: attach `aspire_premium_yearly`

---

## 3. Google Play Console (for testing)

### Internal Testing Track
1. Go to [Google Play Console](https://play.google.com/console/)
2. Create app or select existing
3. Go to Testing > Internal testing
4. Create a new release
5. Add testers (email addresses)
6. Upload AAB when ready

### Create In-App Products
1. Go to Monetize > Products > Subscriptions
2. Create subscription:
   - Product ID: `aspire_premium_monthly`
   - Price: $4.99/month
3. Create another:
   - Product ID: `aspire_premium_yearly`
   - Price: $29.99/year

---

## Checklist

- [ ] Firebase project created
- [ ] `google-services.json` in `android/app/`
- [ ] Firebase Auth enabled (Email + Google)
- [ ] SHA-1 added to Firebase
- [ ] Firestore created
- [ ] RevenueCat project created
- [ ] RevenueCat API key copied
- [ ] Google Play Console app created (can do later)
