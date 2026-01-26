# Testing Checklist

## Day 8: AI Actions & Settings (Current)

### AI Actions Review Sheet (checkbox removed)
- [x] Go to a goal with existing actions and tap "AI Generate"
- [x] Verify the review sheet shows actions without checkboxes (just delete icons)
- [x] Delete one action and tap "Add X Actions"
- [x] Verify remaining actions are added to existing ones

### AI Behavior Setting (append vs replace)
- [x] Go to Settings and verify "AI Generated Actions" toggle exists
- [x] Verify it defaults to ON (append mode)
- [x] Toggle OFF and generate AI actions on a goal with existing actions
- [x] Verify it says "X actions replaced!" and old actions are gone
- [x] Toggle ON and generate AI actions again
- [x] Verify it says "X actions added!" and actions are appended

### Mark Goal Complete (loading indicator)
- [x] Go to a goal with some incomplete actions
- [x] Tap "Mark Goal as Complete"
- [x] Verify confirmation dialog appears
- [x] Tap "Complete" and verify loading dialog shows "Completing goal..."
- [x] Verify all actions get checked off automatically
- [x] Verify celebration triggers after completion

---

## Day 9: RevenueCat & Paywall

### RevenueCat Integration
- [ ] App launches without errors (RevenueCat initialized)
- [ ] Sign in and verify RevenueCat login in logs
- [ ] Sign out and verify RevenueCat logout in logs

### Paywall Screen
- [ ] Go to Settings > Premium
- [ ] Verify paywall screen opens with features list
- [ ] Verify pricing loads (or shows "Unable to load pricing" if no offerings yet)
- [ ] Tap close button to dismiss paywall
- [ ] Test Restore Purchases button

### Goal Limit (Free Tier)
- [ ] Create 3 goals (free tier limit)
- [ ] Try to create 4th goal
- [ ] Verify upgrade dialog appears with "Goal Limit Reached"
- [ ] Tap "Upgrade" and verify paywall opens
- [ ] Tap "Maybe Later" and verify dialog dismisses

### Premium Status (after purchase/test)
- [ ] After purchase, verify can create unlimited goals
- [ ] Verify premium entitlement persists after app restart
