# Testing Checklist

> NOTE: When cleaning this file, only clear unchecked/done tasks.

## Recent Fixes (February 8, 2026)

### 1. Reorder Actions Bug Fix
- [ ] Open a goal with multiple micro-actions
- [ ] Drag an action using the handle on the right
- [ ] Verify actions reorder correctly (not all staying in place)
- [ ] Confirm the new order persists after leaving and returning to the screen

### 2. Terms/Privacy Links on Paywall
- [ ] Open the paywall screen
- [ ] Tap "Terms" link at the bottom
- [ ] Verify it opens https://aspire.sixtusagbo.dev/terms in browser
- [ ] Tap "Privacy Policy" link
- [ ] Verify it opens https://aspire.sixtusagbo.dev/privacy in browser

### 3. Daily Reminder Default (All Users)
- [ ] Create a new account or check new user document in Firebase
- [ ] Verify `dailyReminderEnabled: true` is set by default
- [ ] Verify `reminderHour: 9` and `reminderMinute: 0` are set

### 4. Goal-Specific Reminders (Premium Only)
- [ ] As a premium user, create a new goal
- [ ] Verify goal is created with `reminderEnabled: true`
- [ ] Verify notification is scheduled for 9:00 AM
- [ ] As a free user, create a new goal
- [ ] Verify goal is created with `reminderEnabled: false`
- [ ] Verify no notification is scheduled

### 5. XP Level Calculation Fix
- [ ] Complete an action to earn XP
- [ ] Verify level displays correctly on progress screen
- [ ] If level up occurs, verify celebration is shown
