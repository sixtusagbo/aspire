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

### Terms of Service & Privacy Policy

- [ ] Settings: Tap "Terms of Service" under About section, opens browser
- [ ] Settings: Tap "Privacy Policy" under About section, opens browser
- [ ] Sign Up: Terms checkbox visible below password fields
- [ ] Sign Up: Cannot sign up (email) without checking the checkbox
- [ ] Sign Up: Cannot sign up (Google) without checking the checkbox
- [ ] Sign Up: Tapping "Terms of Service" link opens browser
- [ ] Sign Up: Tapping "Privacy Policy" link opens browser
- [ ] Sign Up: After checking checkbox, sign up works normally

### Returning User Notification Prompt

- [ ] Sign out, set `lastLoginAt` to >1 day ago in Firestore (or wait)
- [ ] Sign back in, home screen shows "Welcome back!" notification dialog
- [ ] Tap "Enable" → requests system notification permission
- [ ] If permission granted → no banner shown
- [ ] Tap "Not now" → banner appears at top of home screen
- [ ] If declined within 7 days, dialog should not reappear on next login

## XP & Level System Fix

### Level Calculation

- [ ] User at 40 XP (level 1), complete action → reaches 50 XP, levels up to 2
- [ ] XP progress shows correct values (not negative, not exceeding max)
- [ ] Progress bar shows correct percentage toward next level

### Level Up Celebration

- [ ] Level up triggers confetti celebration
- [ ] Level Up dialog appears with new level number and title
- [ ] Tap "Awesome!" dismisses dialog
- [ ] If level up + goal completion happen together, goal dialog shown (not level)
