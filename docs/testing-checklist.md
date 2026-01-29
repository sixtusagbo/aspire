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

### Social Sharing

- [x] Complete an action that increases streak → StreakCelebrationDialog appears with Share button
- [x] Tap Share on streak dialog → native share sheet opens with streak message and #Aspire #PacksLight
- [x] Complete all actions on a goal → GoalCompletionDialog appears with trophy animation
- [x] Tap Share on goal completion → native share sheet opens with goal message and #Aspire #PacksLight
- [x] Manually mark goal complete → GoalCompletionDialog appears with Share button

### Tip Card

- [x] Home screen shows "Tip of the Day" card instead of stats bar
- [x] Tips are seeded on first launch (check Firestore 'tips' collection)
- [x] Tip changes daily (same tip throughout the day, different next day)
- [x] Pull to refresh on Home screen refreshes the tip
- [x] Tips display correctly in dark mode
