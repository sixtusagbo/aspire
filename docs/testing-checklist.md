# Testing Checklist

## Settings Screen Completion

### Version Info
- [ ] Open Settings and verify all sections display correctly
- [ ] Check that "About" section shows the correct version (0.1.3+4)

### Manage Subscription (premium only)
- [ ] As premium user, verify "Manage Subscription" option appears under Premium
- [ ] Tap "Manage Subscription" and verify it opens App Store/Play Store subscription settings

### Delete Account
- [ ] Tap "Delete Account" and verify confirmation dialog appears
- [ ] Tap "Cancel" and verify nothing happens
- [ ] (Optional - use test account) Tap "Delete" and verify:
  - [ ] All user data is deleted from Firestore
  - [ ] User is redirected to sign in screen
  - [ ] Toast shows "Account deleted"
