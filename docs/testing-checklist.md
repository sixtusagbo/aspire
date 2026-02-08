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
