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

## 2. Firebase Functions (for AI)

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

## 3. Google Play Console

### Create App

- [x] Go to [Google Play Console](https://play.google.com/console/)
- [x] Click "Create app"
- [x] App name: `Aspire`
- [x] Default language: English
- [x] App or game: App
- [x] Free or paid: Free (we use in-app subscriptions)
- [x] Accept declarations and click "Create app"

### Set Up Payments Profile

- [x] Go to Settings > Payments profile (if prompted)
- [x] Create payments profile
- [x] Enroll for 15% service fee (optional but recommended):
  - Go to Developer account > Associated developer accounts
  - Click "Manage account group"
  - Answer questions about other accounts (select No if none)
  - Click "Review and enrol" for 15% service fee
  - Accept terms

### Upload App Bundle (Required before creating subscriptions)

- [x] Go to Test and release > Testing > Internal testing
- [x] Click "Create new release"
- [x] Upload your AAB file (`make build-appbundle`)
- [x] Add release notes
- [x] Click "Save" then "Review release" then "Start rollout"

### Create Subscriptions

- [x] Go to Monetise with Play > Products > Subscriptions
- [x] Click "Create subscription"
- [x] Create first subscription:
  - Product ID: `aspire_premium_monthly`
  - Name: `Aspire Premium Monthly`
  - Add base plan with ID: `monthly`
  - Type: Auto-renewing
  - Billing period: Monthly
  - Set price: $2.99 USD (select all countries)
  - Save and activate
- [x] Create second subscription:
  - Product ID: `aspire_premium_yearly`
  - Name: `Aspire Premium Yearly`
  - Add base plan with ID: `yearly`
  - Type: Auto-renewing
  - Billing period: Yearly
  - Set price: $17.99 USD (select all countries)
  - Save and activate

### Add License Testers

- [x] Go to Settings > License testing
- [x] Add tester email addresses
- [x] These testers can make test purchases without being charged

---

## 4. RevenueCat Setup

Follow [RevenueCat's official guide](https://www.revenuecat.com/docs/service-credentials/creating-play-service-credentials) for service credentials - this is tricky!

### Create RevenueCat Project

- [x] Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
- [x] Sign up / Log in
- [x] Click "Create new project"
- [x] Name: `Aspire`

### Add Android App

- [x] In your project, go to Apps & providers > Add app
- [x] Select **Google Play Store**
- [x] App name: `Aspire`
- [x] Package name: `dev.sixtusagbo.aspire`

### Get API Key

- [x] Go to your Android app in RevenueCat
- [x] Copy the **Public API Key** (starts with `goog_`)
- [x] Add to your app code (safe to commit - it's a public key)

### Enable Required APIs in Google Cloud

- [x] Go to [Google Cloud Console](https://console.cloud.google.com/)
- [x] Select your Firebase project (same as Google Cloud project)
- [x] Enable these APIs (search in the top bar):
  - **Google Play Android Developer API**
  - **Google Play Developer Reporting API**
  - **Google Cloud Pub/Sub API**

### Create Service Account with Roles

- [x] Go to IAM & Admin > Service Accounts
- [x] Click "Create Service Account"
- [x] Name: `revenuecat`
- [x] Click "Create and Continue"
- [x] **Add these roles** (don't skip!):
  - **Pub/Sub Editor**
  - **Monitoring Viewer**
- [x] Click "Done"
- [x] Click on the new service account > Keys tab > Add Key > Create new key > JSON
- [x] Download the JSON file (keep it secure!)

### Grant Permissions in Play Console

- [x] Go to [Google Play Console](https://play.google.com/console/)
- [x] Go to **Users and permissions** (left sidebar)
- [x] Click **Invite new users**
- [x] Enter the service account email (e.g., `revenuecat@aspire-bc5d7.iam.gserviceaccount.com`)
- [x] **Account permissions** (for ALL apps):
  - [x] View app information and download bulk reports (read only)
- [x] **App permissions** (click "Add app" > select Aspire):
  - [x] View financial data
  - [x] Manage orders and subscriptions
- [x] Click "Invite user" then "Send invite"

### Upload Service Account to RevenueCat

- [x] Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
- [x] Select your Aspire project > Apps & providers > Android app
- [x] Expand "Service account credentials"
- [x] Upload the JSON key file
- [x] Click refresh and wait for "Valid credentials" (all 3 checkmarks green)
- [x] Optionally set up Google developer notifications (Pub/Sub) for real-time updates

### Import Products from Google Play

- [x] Go to Product catalog > Products
- [x] Click "Import Products" or add manually
- [x] Select both subscriptions to import:
  - `aspire_premium_monthly:monthly`
  - `aspire_premium_yearly:yearly`

### Create Entitlement

- [x] Go to Product catalog > Entitlements
- [x] Click "New Entitlement"
- [x] Identifier: `premium`
- [x] Display name: `Premium`
- [x] Click on the entitlement > "Add your first product"
- [x] Attach both subscription products

### Create Offering

- [x] Go to Product catalog > Offerings
- [x] Click "New Offering"
- [x] Fill in offering details:
  - Identifier: `default`
  - Display Name: `Aspire Premium`
- [x] Add Annual package:
  - Click "Add Package"
  - Package: Select `$rc_annual`
  - Product: Select `aspire_premium_yearly:yearly`
  - Description: `Best value - save 50%`
- [x] Add Monthly package:
  - Click "Add Package"
  - Package: Select `$rc_monthly`
  - Product: Select `aspire_premium_monthly:monthly`
  - Description: `Monthly subscription`
- [x] Click "Save"

---

## Quick Checklist

- [x] Firebase project created
- [x] `google-services.json` in `android/app/`
- [x] Firebase Auth enabled (Email + Google)
- [x] SHA-1 added to Firebase
- [x] Firestore created
- [x] Firebase Functions deployed (for AI features)
- [x] Google Play Console app created
- [x] AAB uploaded to internal testing
- [x] Subscriptions created in Play Console
- [x] RevenueCat project created
- [x] Service account with correct roles created
- [x] Service account invited to Play Console with correct permissions
- [x] Service credentials uploaded to RevenueCat (all green)
- [x] Products imported to RevenueCat
- [x] Entitlement `premium` created with products attached
- [x] Offering `default` created with packages
