# Manual Setup Guide

## 1. Firebase Project Setup

### Create Project
- [x] Go to [Firebase Console](https://console.firebase.google.com/)
- [x] Click "Add project"
- [x] Name it `aspire` (or `aspire-app` if taken)
- [x] Disable Google Analytics (optional, speeds up setup)
- [x] Click "Create project"

### Add Android App
- [x] In project overview, click the Android icon
- [x] Package name: `dev.sixtusagbo.aspire`
- [x] App nickname: `Aspire`
- [x] Download `google-services.json`
- [x] Place it in `android/app/google-services.json`

### Enable Authentication
- [x] Go to Build > Authentication
- [x] Click "Get started"
- [x] Enable **Email/Password** provider
- [x] Enable **Google** provider:
  - Add support email
  - Note the Web Client ID (needed for Android)

### Configure Google Sign-In for Android (REQUIRED)

**Without this, Google Sign-In will fail silently!**

- [x] Get your SHA-1 fingerprint:
  ```bash
  cd android && ./gradlew signingReport
  ```
  Look for `SHA1:` under `Variant: debug`

- [x] Go to [Firebase Console](https://console.firebase.google.com/) > Project Settings > Your apps > Android app

- [x] Click "Add fingerprint" and paste the SHA-1

- [x] Download the updated `google-services.json` and replace `android/app/google-services.json`

- [x] Rebuild the app: `flutter clean && flutter run`

### Enable Firestore
- [x] Go to Build > Firestore Database
- [x] Click "Create database"
- [x] Choose nearest region (e.g., `us-central1`)

---

## 2. RevenueCat Setup

### Create Account
- [x] Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
- [x] Sign up / Log in

### Create Project
- [x] Click "Create new project"
- [x] Name: `Aspire`

### Add Android App
- [x] In your project, go to Apps > Add app
- [x] Select **Google Play Store**
- [x] App name: `Aspire`
- [x] Package name: `dev.sixtusagbo.aspire`

### Get API Key
- [x] Go to your Android app in RevenueCat
- [x] Copy the **Public API Key** (starts with `goog_`)
- [x] You'll add this to the app later

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

- [x] Firebase project created
- [x] `google-services.json` in `android/app/`
- [x] Firebase Auth enabled (Email + Google)
- [x] SHA-1 added to Firebase
- [x] Firestore created
- [ ] RevenueCat project created
- [ ] RevenueCat API key copied
- [ ] Google Play Console app created (can do later)
- [ ] Firebase Functions deployed (for AI features)
