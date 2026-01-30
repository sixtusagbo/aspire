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

#### Seeding (do first)

- [x] Go to Settings → Developer → "Seed Goal Templates"
- [x] Verify toast shows "Goal templates seeded!"

#### Template Selection (Goals screen)

- [x] Tap "New Goal" → "Choose from templates" button visible
- [x] Tap "Choose from templates" → template selector sheet opens
- [x] All 15 templates displayed with category icons and colors
- [x] Filter by category works (All, Travel, Career, Finance, Wellness, Personal)
- [x] Templates show target date type where applicable (End of year, 3 months, etc.)
- [x] Select a template → form pre-fills title, description, category
- [x] Target date auto-fills when template has one
- [x] Button text changes to "Change template" after selection
- [x] Autofocus on title field only when NO template selected
- [x] "X suggested actions" text visible when template selected
- [x] Tapping suggested actions opens edit sheet
- [x] Can edit/add/remove actions in edit sheet
- [x] Create goal → micro-actions created from template suggestions

#### Template Selection (Onboarding)

- [x] Template selection auto-fills target date
- [x] Template creates micro-actions (not AI generated)

#### Cleanup (after testing)

- [x] Remove Developer section from settings_screen.dart
- [x] Remove write permission from goal_templates in firestore.rules
- [x] Deploy updated Firestore rules

### Celebration Sound Effects

- [x] Mark goal as complete → celebration sound plays
- [x] Sound plays with goal completion dialog
