# Testing Checklist

> NOTE: When clearing this file, only clear unchecked/done tasks.

## Day 9: RevenueCat & Paywall [KEEP, NEVER REMOVE]

### Premium Status (after purchase/test)
- [ ] After purchase, verify can create unlimited goals
- [ ] Verify premium entitlement persists after app restart
- [ ] Verify premium entitlement persists after user signs out and logs back in

## Day 10: Settings Screen Completion

### Manage Subscription (premium only)
- [ ] As premium user, verify "Manage Subscription" option appears under Premium
- [ ] Tap "Manage Subscription" and verify it opens App Store/Play Store subscription settings

## Day 5 Fixes

### Design Consistency
- [ ] Google OAuth button has pill shape (same as Continue/Enable buttons)
- [ ] Google OAuth button adapts to dark mode properly

### Sign Out
- [ ] Tapping "Sign Out" shows confirmation modal before signing out
- [ ] Cancelling modal returns to settings without signing out

### AI Actions Bug Fix
- [ ] When goal has existing actions (e.g., 5), clicking AI Generate and switching to "Add to existing" does NOT clear the generated actions
- [ ] Actions over the limit are shown greyed out (not deleted)
- [ ] Upgrade prompt appears when over limit for free users

### Reminder Sync to Firebase
- [ ] Set daily reminder time in settings
- [ ] Sign out and sign back in
- [ ] Verify reminder time is preserved (synced from Firebase, not local only)

### Notifications (PENDING FIX)
- [ ] Daily reminder notification fires at scheduled time
- [ ] Notification appears when app is in foreground
- [ ] Notification appears when app is in background
- [ ] Goal-specific reminders fire correctly

## Goals Screen
- [ ] Empty state adapts to dark mode
