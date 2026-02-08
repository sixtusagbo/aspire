# Testing Checklist

> NOTE: When cleaning this file, only clear unchecked/done tasks.

## Recent Fixes (February 8, 2026)

### 1. Reorder Actions Bug Fix
- [x] Open a goal with multiple micro-actions
- [x] Drag an action using the handle on the right
- [x] Verify actions reorder correctly (not all staying in place)
- [x] Confirm the new order persists after leaving and returning to the screen

### 2. Terms/Privacy Links on Paywall
- [x] Open the paywall screen
- [x] Tap "Terms" link at the bottom
- [x] Verify it opens https://aspire.sixtusagbo.dev/terms in browser
- [x] Tap "Privacy Policy" link
- [x] Verify it opens https://aspire.sixtusagbo.dev/privacy in browser

### 3. Daily Reminder Default (All Users)
- [x] Create a new account or check new user document in Firebase
- [x] Verify `dailyReminderEnabled: true` is set by default
- [x] Verify `reminderHour: 9` and `reminderMinute: 0` are set

### 4. Goal-Specific Reminders (Premium Only)
- [x] As a premium user, create a new goal
- [x] Verify goal is created with `reminderEnabled: true`
- [x] Verify notification is scheduled for 9:00 AM
- [x] As a free user, create a new goal
- [x] Verify goal is created with `reminderEnabled: false`
- [x] Verify no notification is scheduled

### 5. Splash Screen - Gabby Attribution
- [ ] Launch the app (or log out to see splash)
- [ ] Verify "Inspired by Gabby Beckford" appears at the bottom of the splash screen
- [ ] Text should be subtle (lighter color, small font)
