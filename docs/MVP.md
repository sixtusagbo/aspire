# Aspire MVP Development Plan

**From dreaming to doing - for ambitious women**

Shipyard Hackathon Entry for Gabby Beckford (@PacksLight)

**Deadline:** February 12, 2026, 11:59 PM PST

**Timeline:**
- Building: Jan 25 - Feb 3 (10 days)
- Testing: Feb 4 - Feb 5 (2 days)
- Submission: Feb 6+ (deadline Feb 12)

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

**Location:** `~/projects/foodpilot`

| FoodPilot              | Aspire Equivalent              |
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
  final String userId;
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

## Development Phases (10 Days)

### Phase 1: Foundation (Days 1-2)

**Day 1: Project Setup**

- [x] Flutter project initialized (Android only)
- [x] Copy folder structure from FoodPilot
- [x] Set up Firebase project (new project: aspire)
- [x] Configure Firebase Auth
- [x] Copy theme system from FoodPilot
- [x] Copy app router pattern
- [ ] Set up RevenueCat account and SDK
- [ ] Landing page (for Google OAuth branding verification)
  - [ ] Homepage with app description
  - [ ] Privacy Policy page
  - [ ] Terms of Service page
  - [ ] Deploy to Vercel

**Day 2: Auth & Core Providers**

- [x] Copy and adapt auth service
- [x] Copy sign-in/sign-up screens
- [x] Adapt for Aspire branding
- [x] Set up Riverpod providers
- [ ] Create goal and micro-action providers
- [ ] Run build_runner, verify everything compiles

**Deliverable:** App launches, user can sign in, theme works

---

### Phase 2: Onboarding & Goal Creation (Days 3-4)

**Day 3: Onboarding & Goal Creation**

- [ ] Welcome screen with value proposition
- [ ] Name collection
- [ ] Goal creation screen
- [ ] Title, description, target date inputs
- [ ] Category selection (travel, career, finance, wellness, personal)
- [ ] Save to Firestore

**Day 4: Micro-Action Setup**

- [ ] Micro-action list for goal
- [ ] Add/edit/delete micro-actions
- [ ] Drag to reorder
- [ ] Notification permission request

**Deliverable:** User can create a goal with micro-actions

---

### Phase 3: Daily Experience (Days 5-6)

**Day 5: Home Screen & Gamification**

- [ ] Today's micro-actions list
- [ ] One-tap completion
- [ ] Progress indicator for each goal
- [ ] Quick stats (streak, XP, level)
- [ ] XP award on task completion (copy from FoodPilot)
- [ ] Streak tracking (consecutive days with at least 1 action)

**Day 6: Celebrations & Notifications**

- [ ] Confetti animation on task completion
- [ ] Bigger celebration on streak milestones (7, 30, etc.)
- [ ] Goal completion celebration
- [ ] Haptic feedback
- [ ] Daily reminder notification
- [ ] Configurable reminder time

**Deliverable:** Core daily loop works - check in, complete tasks, earn XP, see confetti

---

### Phase 4: Progress & Goals View (Days 7-8)

**Day 7: Goals List & Detail**

- [ ] List all goals with progress bar
- [ ] Filter: Active / Completed
- [ ] Goal detail screen
- [ ] Micro-actions list with completion status
- [ ] Mark goal as complete button

**Day 8: Stats & Progress Dashboard**

- [ ] Current streak display
- [ ] Total goals completed
- [ ] Total micro-actions completed
- [ ] This week/month activity

**Deliverable:** User can see all goals and track progress

---

### Phase 5: Monetization & Settings (Days 9-10)

**Day 9: RevenueCat & Paywall**

- [ ] RevenueCat SDK setup
- [ ] Create offerings in RevenueCat dashboard
- [ ] Premium entitlement check
- [ ] Restore purchases
- [ ] Paywall screen design
- [ ] Free tier: 1 active goal
- [ ] Premium: Unlimited goals

**Day 10: Settings & Polish**

- [ ] Settings screen (account, notifications, subscription)
- [ ] Sign out / delete account
- [ ] Empty states with encouraging messages
- [ ] Loading states and error handling

**Deliverable:** Monetization works, app is feature-complete

---

## Testing & Submission (Days 11-12)

**Day 11: Testing**

- [ ] Full flow testing
- [ ] Edge cases and bug fixes
- [ ] Performance optimization

**Day 12: Submission**

- [ ] Record 2-3 minute demo video
- [ ] Write proposal (problem, solution, monetization, roadmap)
- [ ] Technical documentation
- [ ] Screenshots
- [ ] Upload to Google Play Internal Testing
- [ ] Submit on DevPost

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

## Judging Criteria

| Criteria | Weight | Focus |
|----------|--------|-------|
| **Audience Fit** | 30% | Does it solve Gabby's community's problem? |
| **User Experience** | 25% | Is it delightful and easy to use? |
| **Monetization Potential** | 20% | Is the business model viable? |
| **Innovation** | 15% | Is the approach creative and fresh? |
| **Technical Quality** | 10% | Does it work? Is it polished? |

**Note:** Gabby herself reviews top submissions for her brief.

---

## Submission Requirements

1. **App Distribution:** Google Play Internal Testing
2. **Demo Video:** 2-3 minutes showcasing core features and user flow
3. **Written Proposal:** Problem statement, solution overview, monetization strategy, roadmap
4. **Technical Documentation:** Architecture and RevenueCat integration details
5. **Developer Bio:** Background and relevant experience

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

## Next Steps (Day 1)

1. [ ] Copy core files from FoodPilot (theme, router, auth patterns)
2. [ ] Set up Firebase project (aspire)
3. [ ] Configure Firebase Auth
4. [ ] Set up RevenueCat account
5. [ ] Get basic app shell running with routing
6. [ ] Register on DevPost
