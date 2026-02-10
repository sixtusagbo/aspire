# Testing Checklist

> NOTE: When cleaning this file, only clear unchecked/done tasks.

## Free Trial Paywall

- [x] Open paywall from Settings - trial banner and FREE TRIAL badges appear (if trial configured in Play Console)
- [ ] Paywall subtitle reads "Start your free trial today" when trial exists
- [ ] Monthly card subtitle shows green text like "7-Day free trial, then $4.99/mo"
- [ ] Monthly card has FREE TRIAL badge on right
- [ ] Annual card subtitle shows green text like "7-Day free trial, then $29.99/yr"
- [ ] Annual card has FREE TRIAL badge on left, savings badge on right
- [ ] Terms text reads "Free trial, then auto-renews. Cancel anytime."
- [ ] Open paywall without trial configured - looks identical to previous behavior
- [ ] Close button on paywall still works (pops back)

## Paywall After Onboarding

- [ ] Complete onboarding as new user - paywall appears on top of home
- [ ] Dismiss paywall via close button - lands on home screen
- [ ] Paywall shows trial info if trial is configured

## Share Messages

- [x] Share a streak - message includes "Download Aspire on Google Play today!"
- [x] Share a completed goal - message includes "Download Aspire on Google Play today!"
- [x] Both messages still include #Aspire #PacksLight hashtags

## Delete Account

- [x] Tap Delete Account > Confirm - full-screen loading overlay appears
- [x] Back button / swipe back does not dismiss the loading overlay
- [x] On success, navigates to sign-in screen
- [x] On error, loading overlay dismisses and error toast shows

## Theme Mode Selection (Settings)

- [ ] Appearance tile shows between Notifications and Premium sections
- [ ] Subtitle shows current mode (Auto, Light, or Dark)
- [ ] Tap opens dialog with three radio options
- [ ] Select Light - app switches to light theme immediately
- [ ] Select Dark - app switches to dark theme immediately
- [ ] Select Auto - app follows device setting
- [ ] Kill and reopen app - selected theme persists

## Social Links (Settings)

- [x] X logo is visible in dark mode (white circle background)
- [x] X logo looks normal in light mode (no background)
