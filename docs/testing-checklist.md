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

### Goal Templates

- [x] Tap "New Goal" on Goals screen → "Choose from templates" button visible
- [x] Tap "Choose from templates" → template selector sheet opens
- [x] All 15 templates displayed with category icons and colors
- [x] Filter by category works (All, Travel, Career, Finance, Wellness, Personal)
- [x] Select a template → form pre-fills with title, description, and category
- [x] Button text changes to "Change template" after selection
- [x] Templates come from Firestore (seeded on app start)
- [ ] Templates show target date type (End of year, 3 months, 6 months, etc.)
- [ ] Target date auto-fills when template selected (if template has one)
- [ ] "X suggested actions" text visible when template selected
- [ ] Tapping suggested actions opens edit sheet
- [ ] Can edit/add/remove actions in edit sheet
- [ ] Create goal from template creates micro-actions automatically
- [ ] In onboarding, template selection auto-fills target date
- [ ] In onboarding, template creates micro-actions (not AI)

### Celebration Sound Effects

- [x] Mark goal as complete → celebration sound plays
- [x] Sound plays with goal completion dialog
