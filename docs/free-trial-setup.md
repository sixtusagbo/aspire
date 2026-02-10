# Free Trial Setup Guide

How to configure a free trial for Aspire subscriptions via Google Play Console and RevenueCat.

## 1. Google Play Console

### Create an offer with a free trial phase

For each subscription (**aspire_premium_monthly** and **aspire_premium_annual**):

1. Go to **Google Play Console > Aspire > Monetise with Play > Subscriptions**
2. Select the subscription
3. Under **Base plans and offers**, click **Add offer**
4. Fill in:
   - **Offer ID**: `free-trial`
   - **Eligibility criteria**: New customer acquisition > **Never had any subscription**
   - **Tags**: leave empty
5. Under **Phases**, click **Add phase**:
   - **Type**: Free trial
   - **Duration**: 7 days
6. Click **Save**, then **Activate** the offer

### Verification

- The offer should show as "Active" under the subscription's base plan
- Google Play enforces one free trial per user per subscription automatically

## 2. RevenueCat

RevenueCat automatically reads free trial info from the store. No configuration changes are needed in the RevenueCat dashboard.

### Verify RevenueCat sees the trial

1. Go to **RevenueCat Dashboard > Products**
2. Find your Google Play product
3. Click into it - you should see the free trial offer listed under the product details
4. If it doesn't appear, click **Refetch products** to sync from Google Play

## 3. App Code (Already Done)

The paywall code in `lib/features/paywall/paywall_screen.dart` already handles trial detection:

- Checks `storeProduct.defaultOption.freePhase` (Google Play)
- Shows trial banner, badges, and updated text when a trial is detected
- Renders the normal paywall when no trial is configured

## 4. Testing with Licence Testers

Testers are already configured under **Google Play Console > Licence testing** in the **[Aspire] Testers list**. Keep **Licence response** set to **RESPOND_NORMALLY** so testers go through the real purchase flow including the trial.

Licence testers get shortened subscription periods (trial renews in minutes instead of days).

1. Install the app on a real device signed into a tester Gmail account
2. Open the paywall - trial UI elements should appear
3. Purchase - Google Play shows the trial confirmation dialog
4. The subscription auto-renews at the test cadence (every few minutes)

### Reset a test subscription

- Testers can cancel via Google Play subscriptions settings and re-subscribe
- Alternatively, remove and re-add the tester email in the testers list to reset eligibility
