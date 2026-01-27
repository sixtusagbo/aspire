# Testing Checklist

## Day 9: RevenueCat & Paywall

### Setup (see [SETUP.md](SETUP.md#2-revenuecat-setup))
- [x] Create offerings in RevenueCat dashboard
- [x] Create entitlement: `premium`
- [x] Add products: `aspire_premium_monthly`, `aspire_premium_yearly`
- [x] Create offering: `default` with monthly and annual packages

### RevenueCat Integration
- [x] App launches without errors (RevenueCat initialized)
- [x] Sign in and verify RevenueCat login in logs
- [x] Sign out and verify RevenueCat logout in logs

### Paywall Screen
- [x] Go to Settings > Premium
- [x] Verify paywall screen opens with features list
- [x] Verify pricing loads (or shows "Unable to load pricing" if no offerings yet)
- [x] Tap close button to dismiss paywall
- [x] Test Restore Purchases button

### Goal Limit (Free Tier)
- [x] Create 3 goals (free tier limit)
- [x] Try to create 4th goal
- [x] Verify upgrade dialog appears with "Goal Limit Reached"
- [x] Tap "Upgrade" and verify paywall opens
- [x] Tap "Maybe Later" and verify dialog dismisses

### Micro Actions Limit (Free Tier)
- [x] Create a goal with micro actions
- [x] Add micro actions up to free tier limit (5 per goal)
- [x] Try to add 6th micro action manually
- [x] Verify upgrade dialog appears with limit message
- [x] Tap "Upgrade" and verify paywall opens
- [x] Tap "Cancel" and verify dialog dismisses

### AI-Generated Actions Limit
- [x] Generate AI actions for a goal
- [x] Verify review sheet shows action count
- [x] Verify "Add to existing" vs "Replace all" toggle works
- [x] Verify actions over limit are disabled/strikethrough
- [x] Verify "Get more" upgrade link works
- [x] Verify can only add up to limit

### Premium Status (after purchase/test)
- [ ] After purchase, verify can create unlimited goals
- [ ] Verify premium entitlement persists after app restart
