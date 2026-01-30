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

## Bonus Features

### Custom Categories (Premium)

#### As Free User

- [x] Category selector shows preset categories (Travel, Career, Finance, Wellness, Personal)
- [x] "Custom" chip shows with lock icon
- [x] Tapping "Custom" chip navigates to paywall

#### As Premium User

- [x] Category selector shows "Add" button in pink
- [x] Tap "Add" → shows dialog to enter custom category name
- [x] Enter name and tap "Add" → custom category appears in selector
- [x] Custom category chip shows with default icon (category icon)
- [x] Custom category uses default brown color
- [x] Can select custom category when creating a goal
- [x] Goal displays with custom category name in all screens (Home, Goals, Progress, Detail)
- [x] Can edit goal and change to/from custom category
- [x] Long press custom category chip → shows delete confirmation
- [x] Delete custom category → chip removed from selector

### Accessibility

- [ ] Enable "Reduce motion" in device settings → confetti/animations should be skipped
- [ ] Goal completion dialog shows static trophy (no pulse animation) with reduce motion
- [ ] Streak celebration dialog shows static fire (no pulse animation) with reduce motion
- [ ] Secondary text is readable (improved contrast)
- [x] Icon buttons show tooltips on long press
