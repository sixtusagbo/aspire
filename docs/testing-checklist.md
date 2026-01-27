# Testing Checklist

## Day 9: RevenueCat & Paywall

### Setup (see [SETUP.md](SETUP.md#2-revenuecat-setup))
- [ ] Create offerings in RevenueCat dashboard
- [ ] Create entitlement: `premium`
- [ ] Add products: `aspire_premium_monthly`, `aspire_premium_yearly`
- [ ] Create offering: `default` with monthly and annual packages

### RevenueCat Integration
- [ ] App launches without errors (RevenueCat initialized)
- [ ] Sign in and verify RevenueCat login in logs
- [ ] Sign out and verify RevenueCat logout in logs

### Paywall Screen
- [ ] Go to Settings > Premium
- [ ] Verify paywall screen opens with features list
- [ ] Verify pricing loads (or shows "Unable to load pricing" if no offerings yet)
- [ ] Tap close button to dismiss paywall
- [ ] Test Restore Purchases button

### Goal Limit (Free Tier)
- [ ] Create 3 goals (free tier limit)
- [ ] Try to create 4th goal
- [ ] Verify upgrade dialog appears with "Goal Limit Reached"
- [ ] Tap "Upgrade" and verify paywall opens
- [ ] Tap "Maybe Later" and verify dialog dismisses

### Premium Status (after purchase/test)
- [ ] After purchase, verify can create unlimited goals
- [ ] Verify premium entitlement persists after app restart
