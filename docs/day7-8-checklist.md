# Day 7-8 Testing Checklist

## Day 7: AI Micro-Action Generation

### AI Generate Button
- [ ] On goal detail screen with no actions, see "Generate with AI" button in center
- [ ] On goal detail screen with actions, see "AI Generate" button in header row
- [ ] Button shows loading state when clicked

### AI Generation Flow
- [ ] Click "Generate with AI" button
- [ ] Loading spinner appears on button
- [ ] After a few seconds, bottom sheet appears with AI suggestions
- [ ] Should see 5-7 suggested micro-actions

### AI Actions Review Sheet
- [ ] Review sheet shows "AI Suggestions" header with sparkle icon
- [ ] Shows goal title in subtitle
- [ ] Each action has checkbox (all selected by default)
- [ ] Can tap checkbox to deselect/select actions
- [ ] Can tap edit icon to edit action title
- [ ] Can tap delete icon to remove action
- [ ] Bottom shows "Add X Actions" button with count

### Saving AI Actions
- [ ] Tap "Add X Actions" button
- [ ] Bottom sheet closes
- [ ] Actions appear in the goal's micro-actions list
- [ ] Toast shows "X actions added!"
- [ ] Can complete these actions like any other

### Error Handling
- [ ] If not signed in, appropriate error appears
- [ ] If network fails, toast shows "Failed to generate actions"

---

## Day 8: Mark Goal Complete & Progress Screen

### Mark Goal as Complete
- [ ] On goal detail screen, see "Mark Goal as Complete" button (gold outline)
- [ ] Button only appears if goal has at least 1 action
- [ ] Button not shown if goal is already completed
- [ ] Tap button shows confirmation dialog
- [ ] Confirm triggers goal completion celebration (confetti)
- [ ] Haptic feedback occurs
- [ ] Toast shows "Congratulations! Goal completed!"
- [ ] Goal moves to "Completed" filter on goals screen

### Progress Screen - Overview Stats
- [ ] Navigate to Progress tab
- [ ] See "Overview" section with 4 stat cards:
  - Goals Done (completed goals count)
  - Active Goals (in-progress goals count)
  - Actions Done (completed micro-actions count)
  - Total XP
- [ ] Values update when you complete actions/goals

### Progress Screen - Streak Section
- [ ] See streak section with fire emoji
- [ ] Shows current streak (X days)
- [ ] Shows milestone badges (7, 14, 30, 60, 100 days)
- [ ] Achieved milestones show gold checkmark
- [ ] Unachieved milestones show grey lock
- [ ] Shows longest streak count

### Progress Screen - Active Goals
- [ ] See "Active Goals" section if you have any
- [ ] Each goal shows:
  - Category icon and color
  - Goal title
  - Progress percentage
  - Progress bar
  - "X of Y actions completed" text

### Progress Screen - Level Progress
- [ ] See level card with level number in cyan circle
- [ ] Shows "Level X" and level title (Dreamer, Achiever, etc.)
- [ ] Shows current XP and XP needed for next level
- [ ] Shows progress bar toward next level
- [ ] Shows "X XP until Level Y" text

### Dark Mode
- [ ] All Progress screen sections look good in dark mode
- [ ] Goal detail screen looks good in dark mode
- [ ] AI review sheet looks good in dark mode

---

## Quick Test Flow

1. Create a new goal (e.g., "Learn to play guitar")
2. Tap "Generate with AI" - verify loading, then review sheet
3. Edit one of the suggestions
4. Delete one suggestion
5. Deselect one suggestion
6. Tap "Add X Actions" - verify they're saved
7. Go to Progress tab - verify stats
8. Complete a couple micro-actions
9. Go back to Progress - verify XP and actions updated
10. Go to goal detail, tap "Mark Goal as Complete"
11. Verify celebration, then check Progress for completed goals count
