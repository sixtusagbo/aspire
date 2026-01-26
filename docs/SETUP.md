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
- [x] Enable Firebase Functions in console
- [x] Install Firebase CLI: `npm install -g firebase-tools`
- [x] Initialize functions: `firebase init functions`
- [x] Set OpenAI API key as secret:
  ```bash
  make set-openai-key
  # Or directly: firebase functions:secrets:set OPENAI_API_KEY
  ```

### Deploy
- [x] Deploy functions: `make deploy-functions`

---

## 5. Connect RevenueCat to Google Play

### Service Account Setup (Required for RevenueCat)
- [ ] Go to [Google Cloud Console](https://console.cloud.google.com/)
- [ ] Select your Firebase project (same as Google Cloud project)
- [ ] Go to IAM & Admin > Service Accounts
- [ ] Create a service account:
  - Name: `revenuecat-service-account`
  - Role: None (we'll set permissions in Play Console)
- [ ] Click on the created service account > Keys > Add Key > Create new key > JSON
- [ ] Download the JSON file (keep it secure!)

### Link Service Account to Play Console
- [ ] Go to [Google Play Console](https://play.google.com/console/)
- [ ] Settings > API access
- [ ] Link your Google Cloud project if not already linked
- [ ] Under Service accounts, find your new service account
- [ ] Grant access > Add app > Select Aspire > Apply
- [ ] Set permissions: "View financial data" and "Manage orders and subscriptions"

### Add Service Account to RevenueCat
- [ ] Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
- [ ] Select your Aspire project > Android app
- [ ] Go to "Service credentials"
- [ ] Upload the JSON key file from Google Cloud
- [ ] Click "Connect to Google"

---

## Quick Checklist

- [x] Firebase project created
- [x] `google-services.json` in `android/app/`
- [x] Firebase Auth enabled (Email + Google)
- [x] SHA-1 added to Firebase
- [x] Firestore created
- [x] RevenueCat project created
- [x] RevenueCat API key copied
- [ ] Google Play Console app created
- [ ] Service account created and linked to RevenueCat
- [x] Firebase Functions deployed (for AI features)
