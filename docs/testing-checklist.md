# Testing Checklist

> NOTE: When cleaning this file, only clear unchecked/done tasks.

## Swipe-to-Reveal Micro-Actions

- [x] Go to any goal with micro-actions
- [x] Swipe left on a micro-action to reveal Edit and Delete buttons
- [x] Tap Edit - should open edit dialog
- [x] Tap Delete - should show confirmation dialog
- [x] Confirm delete - action should be removed
- [x] Drag handle on the right still works for reordering

## Next Milestone Indicator (Progress Screen)

- [x] Open Progress screen
- [x] Verify "X days to Y-day milestone" badge appears below current streak
- [x] Verify the next milestone in the row is highlighted (pink border, flag icon)
- [x] If all milestones achieved (100+), no next milestone badge should appear

## Notification Sync (Settings)

- [ ] Open Settings screen
- [ ] When system notifications are OFF, daily reminder toggle should be disabled
- [ ] Subtitle should say "Enable notifications first" when disabled
- [ ] When system notifications are ON, daily reminder toggle should be enabled

## Streak Section Updates

- [x] For 0-day streak, shows "None" instead of "0 days"
- [x] For 0-day streak, no next milestone badge appears
- [x] Milestones are scrollable horizontally
- [x] More milestones appear (up to 20k)
- [x] Large milestones show as "1k", "5k", etc.

## Swipe Actions (No Labels)

- [x] Swipe left on micro-action shows icons only (no Edit/Delete text)

## Swipe Hint Tooltip

- [ ] On first visit to a goal with actions, shows "Swipe left for more options" hint below first action
- [ ] Tapping the hint dismisses it
- [ ] Swiping or using edit/delete dismisses it
- [ ] Hint doesn't appear on subsequent visits (stored locally)
