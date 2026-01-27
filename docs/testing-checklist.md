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
- [ ] Toggle reminder ON as premium user -> verify reminder scheduled at 9:00 AM
- [ ] Tap time to change -> verify time picker opens
- [ ] Change time -> verify toast shows updated time
- [ ] Toggle reminder OFF -> verify toast shows "Reminder disabled"
- [ ] Delete goal with reminder -> verify notification cancelled
