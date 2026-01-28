# Testing Checklist

## Day 9: RevenueCat & Paywall [KEEP, NEVER REMOVE]

### Premium Status (after purchase/test)
- [ ] After purchase, verify can create unlimited goals
- [ ] Verify premium entitlement persists after app restart
- [ ] Verify premium entitlement persists after user signs out and logs back in

## Day 10: Settings Screen Completion

### Version Info
- [x] Open Settings and verify all sections display correctly
- [x] Check that "About" section shows the correct version (0.1.3+4)

### Manage Subscription (premium only)
- [ ] As premium user, verify "Manage Subscription" option appears under Premium
- [ ] Tap "Manage Subscription" and verify it opens App Store/Play Store subscription settings

### Delete Account
- [x] Tap "Delete Account" and verify confirmation dialog appears
- [x] Tap "Cancel" and verify nothing happens
- [ ] (Optional - use test account) Tap "Delete" and verify:
  - [ ] All user data is deleted from Firestore
  - [ ] User is redirected to sign in screen
  - [ ] Toast shows "Account deleted"
