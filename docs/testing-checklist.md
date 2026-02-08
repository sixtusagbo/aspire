# Testing Checklist

> NOTE: When cleaning this file, only clear unchecked/done tasks.

## Day 9: RevenueCat & Paywall

### Premium Status (after purchase/test)

- [ ] Verify premium entitlement persists after app restart
- [ ] Verify premium entitlement persists after user signs out and logs back in

## Day 10: Settings Screen Completion

### Manage Subscription (premium only)

- [ ] As premium user, verify "Manage Subscription" option appears under Premium
- [ ] Tap "Manage Subscription" and verify it opens App Store/Play Store subscription settings

## Notification Flow Fixes

### Onboarding Notification Step

- [x] Tap "Enable Notifications" then "Don't Allow" on system prompt → loading stops, proceeds to next step
- [ ] Tap "Maybe later" to skip → home screen shows only banner (no dialog) (not working, it still shows dialog) (this is still not working)

### Home Screen Notifications

- [x] Fresh sign-in with notifications disabled and no recent decline → notification dialog appears
- [x] After declining dialog → banner still shows, dialog doesn't reappear for 7 days
- [x] Tap "Enable" on banner when previously denied → opens system settings
- [x] After enabling in system settings and returning → banner disappears (it doesn't disappear till I hot restart)

### Settings Notifications

- [x] Toggle notifications OFF when enabled → opens system settings
- [ ] After disabling in system settings and returning → toggle reflects new state (returning doesn't work, app just shows black screen, should I test it with an apk?)

## Goal Form Focus

- [ ] Apply template in onboarding goal step → keyboard dismisses (doesn't dismiss) (still not working)
- [x] Apply template in create goal sheet → keyboard dismisses

## XP & Level System Fix

### Level Calculation

- [x] User at 40 XP (level 1), complete action → reaches 50 XP, levels up to 2
- [x] XP progress shows correct values (not negative, not exceeding max)
- [x] Progress bar shows correct percentage toward next level

### Level Up Celebration

- [x] Level up triggers confetti celebration
- [x] Level Up dialog appears with new level number and title
- [x] Tap "Awesome!" dismisses dialog
- [x] If level up + goal completion happen together, goal dialog shown (not level)
