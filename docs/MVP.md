# GoalPilot MVP Development Plan

**From dreaming to doing - for ambitious women**

Shipyard Hackathon Entry for Gabby Beckford (@PacksLight)

**Deadline:** February 12, 2026 (19 days from Jan 25)

---

## The Brief (Gabby's Words)

> "Help women in their late twenties to late forties build their dream lives and take their dream trips. They want to see the world, travel solo, negotiate six figure salaries, achieve financial freedom. They want it all."

> "The problem is there's still this massive gap between inspiration and action. Sometimes they still get stuck waiting for permission, waiting to feel confident."

> "My dream app combines mindset with micro actions. Daily challenges, wins tracking, gamification - maybe confetti even popping up when they achieve one of their bucket list dreams."

> "Think ambitious, worldly, warm. Help ambitious women go from dreaming to doing as fast and as fun as possible."

---

## Target Audience

- Women ages 25-45
- Ambitious, smart, adventurous
- Want: Travel, career advancement, financial freedom, bold life experiences
- Struggle: Going from inspiration → action, waiting for "permission"
- Trust Gabby to help them close the gap

---

## Tech Stack

| Component        | Technology         | Rationale                                    |
| ---------------- | ------------------ | -------------------------------------------- |
| Framework        | Flutter            | Android (required), can add iOS later        |
| State Management | hooks_riverpod v3  | Borrowed from FoodPilot                      |
| Database         | Firebase Firestore | Real-time sync, auth integration             |
| Authentication   | Firebase Auth      | Google Sign-In + email/password              |
| AI               | OpenAI API         | Goal → micro-action breakdown                |
| Monetization     | RevenueCat         | Required for hackathon                       |
| Notifications    | Local              | Daily micro-action reminders                 |

---

## MVP Scope (19 Days)

### Core Value Proposition

Turn big dreams into daily micro-actions with gamified tracking and celebration.

### What's IN the MVP

1. **Onboarding** - Name, goals setup, notification preferences
2. **Goal Creation** - Create a dream/goal with deadline
3. **AI Micro-Action Breakdown** - OpenAI API generates actionable daily tasks from goal
4. **Daily Check-In** - One-tap task completion
5. **Streaks & XP** - Gamification borrowed from FoodPilot
6. **Confetti Celebrations** - On task completion, streak milestones, goal completion
7. **Progress Dashboard** - Visual progress on each goal
8. **Premium Paywall** - RevenueCat integration (required)

### What's OUT (V2 - Post-MVP to Improve Chances)

If time permits before deadline, add in priority order:

1. **Goal Templates** - Pre-made goals for common dreams (travel, career, finance)
2. **Challenges** - Weekly community challenges
3. **Joint Goals** - Partner with a friend on shared goals
4. **Social Sharing** - Share wins to social media
5. **AI Coaching** - Motivational nudges and advice

---

## Reusable from FoodPilot

| FoodPilot              | GoalPilot Equivalent              |
| ---------------------- | --------------------------------- |
| Auth (Firebase)        | Same - copy directly              |
| Theme system           | Same - copy directly              |
| Gamification stats     | Adapt for goals                   |
| XP/Level system        | Same concept                      |
| Streak tracking        | Same concept                      |
| Notification service   | Adapt for micro-actions           |
| App router structure   | Same pattern                      |
| Settings screen        | Adapt                             |
| Onboarding flow        | Adapt for goal setup              |

---

## Data Models

### User

```dart
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
}
```

### Goal

```dart
class Goal {
  final String id;
  final String userId;
  final String title;           // "Visit Japan"
  final String? description;    // "Experience cherry blossom season"
  final DateTime? targetDate;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final String category;        // travel, career, finance, wellness, personal
}
```

### MicroAction

```dart
class MicroAction {
  final String id;
  final String goalId;
  final String userId;
  final String title;           // "Research flight prices"
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? scheduledFor; // For daily reminders
  final int sortOrder;
}
```

### DailyLog

```dart
class DailyLog {
  final String id;
  final String odayuserId;
  final DateTime date;
  final int actionsCompleted;
  final int xpEarned;
  final List<String> completedActionIds;
}
```

---

## Firestore Structure

```
/users/{userId}
  - name, email, xp, level, streak, isPremium, etc.

/goals/{goalId}
  - userId, title, description, targetDate, isCompleted, category

/micro_actions/{actionId}
  - goalId, userId, title, isCompleted, scheduledFor, sortOrder

/daily_logs/{date}_{userId}
  - userId, date, actionsCompleted, xpEarned, completedActionIds
```

---

## Development Phases

### Phase 1: Foundation (Days 1-3)

**Day 1: Project Setup**

- [x] Flutter project initialized (Android only)
- [ ] Copy folder structure from FoodPilot
- [ ] Set up Firebase project (new project: goalpilot)
- [ ] Configure Firebase Auth
- [ ] Copy theme system from FoodPilot
- [ ] Copy app router pattern
- [ ] Set up RevenueCat account and SDK

**Day 2: Auth & Theme**

- [ ] Copy and adapt auth service
- [ ] Copy sign-in/sign-up screens
- [ ] Adapt for GoalPilot branding
- [ ] Test Google Sign-In on Android

**Day 3: Core Providers**

- [ ] Set up Riverpod providers
- [ ] Copy gamification stats provider pattern
- [ ] Create goal provider
- [ ] Create micro-action provider
- [ ] Run build_runner, verify everything compiles

**Deliverable:** App launches, user can sign in, theme works

---

### Phase 2: Onboarding & Goal Creation (Days 4-6)

**Day 4: Onboarding Flow**

- [ ] Welcome screen with value proposition
- [ ] Name collection
- [ ] First goal creation prompt
- [ ] Notification permission request

**Day 5: Goal Creation**

- [ ] Goal creation screen
- [ ] Title, description, target date inputs
- [ ] Category selection (travel, career, finance, wellness, personal)
- [ ] Save to Firestore

**Day 6: Micro-Action Setup**

- [ ] Micro-action list for goal
- [ ] Add/edit/delete micro-actions
- [ ] Drag to reorder
- [ ] Schedule actions for specific days (optional)

**Deliverable:** User can create a goal with micro-actions

---

### Phase 3: Daily Experience (Days 7-10)

**Day 7: Home Screen**

- [ ] Today's micro-actions list
- [ ] One-tap completion
- [ ] Progress indicator for each goal
- [ ] Quick stats (streak, XP, level)

**Day 8: Check-In & Gamification**

- [ ] XP award on task completion (copy from FoodPilot)
- [ ] Streak tracking (consecutive days with at least 1 action)
- [ ] Level-up logic

**Day 9: Confetti & Celebrations**

- [ ] Confetti animation on task completion
- [ ] Bigger celebration on streak milestones (7, 30, etc.)
- [ ] Goal completion celebration
- [ ] Haptic feedback

**Day 10: Notifications**

- [ ] Daily reminder notification
- [ ] Copy notification service from FoodPilot
- [ ] Adapt for "Your micro-actions are waiting!"
- [ ] Configurable reminder time

**Deliverable:** Core daily loop works - check in, complete tasks, earn XP, see confetti

---

### Phase 4: Progress & Goals View (Days 11-13)

**Day 11: Goals List Screen**

- [ ] List all goals
- [ ] Progress bar per goal
- [ ] Filter: Active / Completed
- [ ] Tap to view goal details

**Day 12: Goal Detail Screen**

- [ ] Goal info (title, description, target date)
- [ ] Micro-actions list with completion status
- [ ] Overall progress percentage
- [ ] Mark goal as complete button

**Day 13: Stats & Progress Dashboard**

- [ ] Current streak display
- [ ] Total goals completed
- [ ] Total micro-actions completed
- [ ] This week/month activity

**Deliverable:** User can see all goals and track progress

---

### Phase 5: Monetization & Settings (Days 14-16)

**Day 14: RevenueCat Integration**

- [ ] RevenueCat SDK setup
- [ ] Create offerings in RevenueCat dashboard
- [ ] Premium entitlement check
- [ ] Restore purchases

**Day 15: Paywall & Premium**

- [ ] Paywall screen design
- [ ] Free tier: 1 active goal, basic features
- [ ] Premium: Unlimited goals, advanced stats
- [ ] Purchase flow
- [ ] Test on Android

**Day 16: Settings Screen**

- [ ] Account info
- [ ] Notification preferences
- [ ] Manage subscription
- [ ] Sign out
- [ ] Delete account

**Deliverable:** Monetization works, premium unlocks features

---

### Phase 6: Polish & Submit (Days 17-19)

**Day 17: UI Polish**

- [ ] Consistent styling throughout
- [ ] Empty states with encouraging messages
- [ ] Loading states
- [ ] Error handling

**Day 18: Testing & Bug Fixes**

- [ ] Full flow testing
- [ ] Edge cases
- [ ] Fix critical bugs
- [ ] Performance check

**Day 19: Submission**

- [ ] Record demo video (required)
- [ ] Write submission description
- [ ] Screenshots
- [ ] Upload to Google Play Internal Testing
- [ ] Submit on Devpost

**Deliverable:** App submitted to hackathon

---

## UI/UX Direction

### Vibe: "Ambitious, worldly, warm"

- **Colors:** Warm purples/magentas (empowering), soft golds (achievement), clean whites
- **Typography:** Modern, confident, readable
- **Imagery:** Travel, success, celebration
- **Tone:** Encouraging but not patronizing, action-oriented

### Key Screens

1. **Home** - Today's micro-actions front and center
2. **Goals** - All dreams/goals with progress
3. **Progress** - Stats, streaks, achievements
4. **Settings** - Account, notifications, premium

### Confetti Moments

- Complete a micro-action: Small confetti burst
- Complete all daily actions: Medium celebration
- Hit streak milestone (7, 30, 100): Big celebration
- Complete a goal: Full-screen confetti + special message

---

## Premium Features (RevenueCat)

### Free Tier

- 1 active goal
- 5 micro-actions per goal
- Basic progress tracking
- Daily reminders

### Premium ($4.99/month or $29.99/year)

- Unlimited goals
- Unlimited micro-actions
- Detailed analytics
- Priority support
- Custom reminder times

---

## Success Criteria (Judging)

Per hackathon rules, judged on:

1. **Technical execution** - Does it work? Is it polished?
2. **Audience fit** - Does it solve Gabby's community's problem?
3. **Product quality** - Is it delightful to use?
4. **Monetization potential** - Is the business model viable?

---

## Risk Mitigation

| Risk                      | Mitigation                                    |
| ------------------------- | --------------------------------------------- |
| Time crunch               | Borrow heavily from FoodPilot                 |
| RevenueCat issues         | Set up early, test on Day 14                  |
| Scope creep               | Strict MVP, no AI features                    |
| Android-only limitation   | Focus on polish, not platform breadth         |

---

## Daily Schedule Template

| Time        | Activity                      |
| ----------- | ----------------------------- |
| Morning     | Code core feature             |
| Afternoon   | Continue + test               |
| Evening     | Review, plan tomorrow         |

---

## Next Steps (Tonight)

1. [ ] Copy core files from FoodPilot
2. [ ] Set up Firebase project
3. [ ] Set up RevenueCat account
4. [ ] Get basic app shell running
5. [ ] Register on Devpost
