# Testing Checklist

## Day 9: RevenueCat & Paywall

### Premium Status (after purchase/test)
- [ ] After purchase, verify can create unlimited goals
- [ ] Verify premium entitlement persists after app restart
- [ ] Verify premium entitlement persists after user signs out and logs back in

## Day 10: Settings & Polish

### Custom Reminders (Premium Feature)
- [x] Open goal detail screen
- [x] Verify "Custom Reminder" section visible with Premium badge
- [x] Toggle reminder ON as free user -> verify premium dialog appears

### Premium Features (with debug bypass)
- [x] Enable debug bypass in RevenueCatService
- [x] Create more than 3 goals (unlimited goals)
- [x] Add more than 5 actions per goal (up to 10)
- [x] Toggle custom reminder ON -> verify scheduled at 9:00 AM
- [x] Tap time to change -> verify time picker opens
- [x] Change time -> verify toast shows updated time
- [x] Toggle reminder OFF -> verify toast shows "Reminder disabled"
- [x] Delete goal with reminder -> verify notification cancelled
- [x] IMPORTANT: Remove debug bypass before release
