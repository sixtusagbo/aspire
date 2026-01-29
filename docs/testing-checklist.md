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


## UX Overhaul: Theme, Dark Mode & Gradient Buttons

### Theme System
- [x] Dark mode background is deep purple-black (#150114), not cold grey
- [x] Light mode background is warm off-white (#FDF8F5), not pure white
- [x] Card surfaces feel warm in both light and dark mode
- [x] Dark mode borders have warm tint (no cold grey borders)

### Auth Screens
- [x] Sign In: "Continue" button has pink-to-coral gradient with pill shape
- [x] Sign In: Dark mode - background, text, inputs all adapt correctly
- [x] Sign Up: "Continue" button has pink-to-coral gradient with pill shape
- [x] Sign Up: Dark mode - background, text, inputs all adapt correctly

### Onboarding Flow
- [x] Welcome Step: "Let's Go" button has gradient style
- [x] Name Step: "Continue" button has gradient, disabled state is grey
- [x] Name Step: Dark mode - input field and back button adapt correctly
- [x] Goal Setup Step: "Start My Journey" button has gradient style
- [x] Goal Setup Step: Category chips adapt to dark mode
- [x] Goal Setup Step: Date picker area adapts to dark mode
- [x] Notification Step: "Enable Notifications" button has gradient style
- [x] Notification Step: Reminder toggle and time picker adapt to dark mode

### Home Screen
- [x] Stats bar has proper dark background (not white)
- [x] Goal cards adapt to dark mode (no white/light grey backgrounds)
- [x] Category icons use correct centralized colors

### Goals Screen
- [x] Goal list cards adapt to dark mode
- [ ] Empty state adapts to dark mode
- [x] Category colors/icons display correctly from centralized source

### Goal Detail Screen
- [x] Category chip uses centralized colors
- [x] Description and progress bar adapt to dark mode
- [x] "Custom Reminder" section background adapts to dark mode
- [x] AI Actions review sheet adapts to dark mode
- [x] Mode toggle buttons (Add/Replace) adapt to dark mode

### Create Goal Sheet
- [x] "Create Goal" button has gradient style
- [x] Category chips adapt to dark mode (no grey.shade100)

### Progress Screen
- [x] All stat cards adapt to dark mode
- [x] Text colors and backgrounds adapt (no grey.shade* visible)
- [x] Streak section and milestones adapt to dark mode

### Paywall Screen
- [x] Pricing cards readable in dark mode
- [x] Feature list and text adapt to dark mode

### Streak Celebration Dialog
- [x] Dialog background adapts to dark mode
- [x] Text colors adapt to dark mode

### General
- [x] No jarring white or light grey backgrounds anywhere in dark mode
- [x] Gradient buttons have subtle glow effect in both modes
- [x] Overall vibe feels warm, bold, and travel-inspired (not corporate)

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
