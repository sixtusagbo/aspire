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

- [ ] Category selector shows preset categories (Travel, Career, Finance, Wellness, Personal)
- [ ] "Custom" chip shows with lock icon
- [ ] Tapping "Custom" chip navigates to paywall

#### As Premium User

- [ ] Category selector shows "Add" button in pink
- [ ] Tap "Add" → shows dialog to enter custom category name
- [ ] Enter name and tap "Add" → custom category appears in selector
- [ ] Custom category chip shows with default icon (category icon)
- [ ] Custom category uses default brown color
- [ ] Can select custom category when creating a goal
- [ ] Goal displays with custom category name in all screens (Home, Goals, Progress, Detail)
- [ ] Can edit goal and change to/from custom category
- [ ] Long press custom category chip → shows delete confirmation
- [ ] Delete custom category → chip removed from selector

### Accessibility

- [ ] Enable "Reduce motion" in device settings → confetti/animations should be skipped
- [ ] Goal completion dialog shows static trophy (no pulse animation) with reduce motion
- [ ] Streak celebration dialog shows static fire (no pulse animation) with reduce motion
- [ ] Secondary text is readable (improved contrast)
- [x] Icon buttons show tooltips on long press
