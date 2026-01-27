# Testing Checklist

## Day 9: RevenueCat & Paywall

### Premium Status (after purchase/test)
- [ ] After purchase, verify can create unlimited goals
- [ ] Verify premium entitlement persists after app restart
- [ ] Verify premium entitlement persists after user signs out and logs back in

## Day 10: Settings & Polish

### Custom Reminders (Premium Feature)
- [ ] Open goal detail screen
- [ ] Verify "Custom Reminder" section visible with Premium badge
- [ ] Toggle reminder ON as free user -> verify premium dialog appears

### Premium Features (with debug bypass)
- [ ] Enable debug bypass in RevenueCatService
- [ ] Create more than 3 goals (unlimited goals)
- [ ] Add more than 5 actions per goal (up to 10)
- [ ] Toggle custom reminder ON -> verify scheduled at 9:00 AM
- [ ] Tap time to change -> verify time picker opens
- [ ] Change time -> verify toast shows updated time
- [ ] Toggle reminder OFF -> verify toast shows "Reminder disabled"
- [ ] Delete goal with reminder -> verify notification cancelled
- [ ] IMPORTANT: Remove debug bypass before release
