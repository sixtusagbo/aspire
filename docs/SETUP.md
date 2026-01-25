# Manual Setup Guide

## 1. Firebase Project Setup

### Create Project
- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Click "Add project"
- [ ] Name it `aspire` (or `aspire-app` if taken)
- [ ] Disable Google Analytics (optional, speeds up setup)
- [ ] Click "Create project"

### Add Android App
- [ ] In project overview, click the Android icon
- [ ] Package name: `dev.sixtusagbo.aspire`
- [ ] App nickname: `Aspire`
- [ ] Download `google-services.json`
- [ ] Place it in `android/app/google-services.json`

### Enable Authentication
- [ ] Go to Build > Authentication
- [ ] Click "Get started"
- [ ] Enable **Email/Password** provider
- [ ] Enable **Google** provider:
  - Add support email
  - Note the Web Client ID (needed for Android)

### Configure Google Sign-In for Android (REQUIRED)

**Without this, Google Sign-In will fail silently!**

- [ ] Get your SHA-1 fingerprint:
  ```bash
  cd android && ./gradlew signingReport
  ```
  Look for `SHA1:` under `Variant: debug`

- [ ] Go to [Firebase Console](https://console.firebase.google.com/) > Project Settings > Your apps > Android app

- [ ] Click "Add fingerprint" and paste the SHA-1

- [ ] Download the updated `google-services.json` and replace `android/app/google-services.json`

- [ ] Rebuild the app: `flutter clean && flutter run`

### Enable Firestore
- [ ] Go to Build > Firestore Database
- [ ] Click "Create database"
- [ ] Start in **test mode** (we'll add rules later)
- [ ] Choose nearest region (e.g., `us-central1`)

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
- [ ] Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
- [ ] Sign up / Log in

### Create Project
- [ ] Click "Create new project"
- [ ] Name: `Aspire`

### Add Android App
- [ ] In your project, go to Apps > Add app
- [ ] Select **Google Play Store**
- [ ] App name: `Aspire`
- [ ] Package name: `dev.sixtusagbo.aspire`

### Get API Key
- [ ] Go to your Android app in RevenueCat
- [ ] Copy the **Public API Key** (starts with `goog_`)
- [ ] You'll add this to the app later

### Create Products (Do after Google Play Console setup)
- [ ] Go to Products > Entitlements
- [ ] Create entitlement: `premium`
- [ ] Go to Products > Products
- [ ] Add products (after creating in Google Play Console):
  - `aspire_premium_monthly` ($4.99/month)
  - `aspire_premium_yearly` ($29.99/year)

### Create Offering
- [ ] Go to Products > Offerings
- [ ] Create offering: `default`
- [ ] Add packages:
  - Monthly: attach `aspire_premium_monthly`
  - Annual: attach `aspire_premium_yearly`

---

## 3. Google Play Console (for testing)

### Internal Testing Track
- [ ] Go to [Google Play Console](https://play.google.com/console/)
- [ ] Create app or select existing
- [ ] Go to Testing > Internal testing
- [ ] Create a new release
- [ ] Add testers (email addresses)
- [ ] Upload AAB when ready

### Create In-App Products
- [ ] Go to Monetize > Products > Subscriptions
- [ ] Create subscription:
  - Product ID: `aspire_premium_monthly`
  - Price: $4.99/month
- [ ] Create another:
  - Product ID: `aspire_premium_yearly`
  - Price: $29.99/year

---

## 4. Firebase Functions (for AI)

### Setup
- [ ] Enable Firebase Functions in console
- [ ] Install Firebase CLI: `npm install -g firebase-tools`
- [ ] Initialize functions: `firebase init functions`
- [ ] Set OpenAI API key as secret:
  ```bash
  firebase functions:secrets:set OPENAI_API_KEY
  ```

### Deploy
- [ ] Deploy functions: `firebase deploy --only functions`

---

## Quick Checklist

- [ ] Firebase project created
- [ ] `google-services.json` in `android/app/`
- [ ] Firebase Auth enabled (Email + Google)
- [ ] SHA-1 added to Firebase
- [ ] Firestore created
- [ ] RevenueCat project created
- [ ] RevenueCat API key copied
- [ ] Google Play Console app created (can do later)
- [ ] Firebase Functions deployed (for AI features)
