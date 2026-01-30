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
- [ ] Go to Settings → Developer → "Seed Goal Templates"
- [ ] Verify toast shows "Goal templates seeded!"

#### Template Selection (Goals screen)
- [ ] Tap "New Goal" → "Choose from templates" button visible
- [ ] Tap "Choose from templates" → template selector sheet opens
- [ ] All 15 templates displayed with category icons and colors
- [ ] Filter by category works (All, Travel, Career, Finance, Wellness, Personal)
- [ ] Templates show target date type where applicable (End of year, 3 months, etc.)
- [ ] Select a template → form pre-fills title, description, category
- [ ] Target date auto-fills when template has one
- [ ] Button text changes to "Change template" after selection
- [ ] Autofocus on title field only when NO template selected
- [ ] "X suggested actions" text visible when template selected
- [ ] Tapping suggested actions opens edit sheet
- [ ] Can edit/add/remove actions in edit sheet
- [ ] Create goal → micro-actions created from template suggestions

#### Template Selection (Onboarding)
- [ ] Template selection auto-fills target date
- [ ] Template creates micro-actions (not AI generated)

#### Cleanup (after testing)
- [ ] Remove Developer section from settings_screen.dart
- [ ] Remove write permission from goal_templates in firestore.rules
- [ ] Deploy updated Firestore rules

### Celebration Sound Effects

- [x] Mark goal as complete → celebration sound plays
- [x] Sound plays with goal completion dialog
