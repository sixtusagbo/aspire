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


## Day 10: Empty States & Loading

### Empty States
- [x] Progress Screen: When no active goals, verify encouraging message shows
- [x] Home Screen: When no goals exist, verify empty state with "Create a Goal" button
- [x] Goals Screen: When no goals, verify empty state message
- [x] Goal Detail Screen: When no actions, verify AI suggestion empty state

### Loading States
- [x] Home Screen: Verify loading spinner shows while goals load
- [x] Goals Screen: Verify loading spinner shows while data loads
- [x] Goal Detail Screen: Verify loading spinner shows while loading
- [x] Progress Screen: Verify loading spinner shows while loading
- [x] Settings Screen: Verify "Checking..." shows while loading notification/premium status
