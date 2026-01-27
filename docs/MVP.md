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

| Component        | Technology                    | Rationale                                                     |
| ---------------- | ----------------------------- | ------------------------------------------------------------- |
| Framework        | Flutter                       | Android and iOS                                               |
| State Management | hooks_riverpod v3             | Borrowed from FoodPilot                                       |
| Database         | Firebase Firestore            | Real-time sync, auth integration                              |
| Authentication   | Firebase Auth                 | Google Sign-In + email/password                               |
| AI               | OpenAI via Firebase Functions | Goal → micro-action breakdown (API key protected server-side) |
| Monetization     | RevenueCat                    | Required for hackathon                                        |
| Notifications    | Local                         | Daily micro-action reminders                                  |

---

## MVP Scope (19 Days)

### Core Value Proposition

Turn big dreams into daily micro-actions with gamified tracking and celebration.

### What's IN the MVP

1. **Onboarding** - Name, goals setup, notification preferences
2. **Goal Creation** - Create a dream/goal with deadline
3. **AI Micro-Action Breakdown** - OpenAI generates actionable daily tasks (5 suggestions free, 10 premium)
4. **Daily Check-In** - One-tap task completion
5. **Streaks & XP** - Gamification borrowed from FoodPilot
6. **Confetti Celebrations** - On task completion, streak milestones, goal completion
7. **Progress Dashboard** - Visual progress on each goal
8. **Premium Paywall** - RevenueCat integration (required)

### What's OUT (V2 - Post-MVP to Improve Chances)

If time permits before deadline, add in priority order:

1. **Celebration Sound Effects** - Audio feedback for confetti and streak increases
2. **Goal-Specific Reminders** - Set different reminder times for each goal, only if the user decides to be remided differently about this goal, it should be shown in goal creation and by default turned off.
3. **Goal Templates** - Pre-made goals for common dreams (travel, career, finance)
4. **Challenges** - Weekly community challenges
5. **Joint Goals** - Partner with a friend on shared goals
6. **Social Sharing** - Share wins to social media
7. **AI Coaching** - Motivational nudges and advice
8. **Home Screen Widget** - Android widget showing goals and progress at a glance

---

## Reusable from FoodPilot

**Location:** `~/projects/foodpilot`

| FoodPilot            | Aspire Equivalent       |
| -------------------- | ----------------------- |
| Auth (Firebase)      | Same - copy directly    |
| Theme system         | Same - copy directly    |
| Gamification stats   | Adapt for goals         |
| XP/Level system      | Same concept            |
| Streak tracking      | Same concept            |
| Notification service | Adapt for micro-actions |
| App router structure | Same pattern            |
| Settings screen      | Adapt                   |
| Onboarding flow      | Adapt for goal setup    |

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

- [x] Flutter project initialized (Android and iOS)
- [x] Copy folder structure from FoodPilot
- [x] Set up Firebase project (new project: aspire)
- [x] Configure Firebase Auth
- [x] Copy theme system from FoodPilot
- [x] Copy app router pattern
- [x] Landing page (for Google OAuth branding verification)
  - [x] Homepage with app description
  - [x] Privacy Policy page
  - [x] Terms of Service page
  - [x] Deploy to Vercel
  - [x] Google OAuth branding verified

**Day 2: Auth & Core Providers**

- [x] Copy and adapt auth service
- [x] Copy sign-in/sign-up screens
- [x] Adapt for Aspire branding
- [x] Set up Riverpod providers
- [x] Create goal and micro-action models and providers
- [x] Run build_runner, verify everything compiles

**Deliverable:** App launches, user can sign in, theme works

---

### Phase 2: Onboarding & Goal Creation (Days 3-4)

**Day 3: Onboarding & Goal Creation**

- [x] Welcome screen with value proposition
- [x] Name collection (skipped for OAuth users who have displayName)
- [x] Goal creation screen
- [x] Title, description, target date inputs
- [x] Category selection (travel, career, finance, wellness, personal)
- [x] Save to Firestore

**Day 4: Micro-Action Setup**

- [x] Micro-action list for goal
- [x] Add/edit/delete micro-actions
- [x] Drag to reorder
- [x] Notification permission request

**Deliverable:** User can create a goal with micro-actions

---

### Phase 3: Daily Experience (Days 5-6)

**Day 5: Home Screen & Gamification**

- [x] Today's micro-actions list
- [x] One-tap completion
- [x] Progress indicator for each goal
- [x] Quick stats (streak, XP, level)
- [x] XP award on task completion (copy from FoodPilot)
- [x] Streak tracking (consecutive days with at least 1 action)

**Day 6: Celebrations & Notifications**

- [x] Confetti animation on task completion
- [x] Bigger celebration on streak milestones (7, 30, etc.)
- [x] Goal completion celebration
- [x] Haptic feedback
- [x] Daily reminder notification
- [x] Configurable reminder time
- [x] Streak increase popup (Duolingo-style with animated fire emoji and next milestone)

**Deliverable:** Core daily loop works - check in, complete tasks, earn XP, see confetti

---

### Phase 4: AI Micro-Actions & Goals (Days 7-8)

**Day 7: AI Micro-Action Generation**

- [x] Set up Firebase Functions project
- [x] Create OpenAI integration function (secure API key server-side)
- [x] AI generates micro-actions from goal title/description
- [x] "Generate Actions" button on goal detail screen
- [x] Loading state while AI generates
- [x] Display generated actions for user review
- [x] User can edit/delete suggestions before saving
- [x] "Save All" to confirm AI-generated actions

**Day 8: Goals Polish & Progress**

- [x] List all goals with progress bar
- [x] Filter: Active / Completed
- [x] Goal detail screen
- [x] Micro-actions list with completion status
- [x] Edit goal functionality
- [x] Delete goal functionality
- [x] Mark goal as complete button
- [x] Progress screen content (stats dashboard)

**Deliverable:** AI helps break down goals, user can see all goals and track progress

---

### Phase 5: Monetization & Settings (Days 9-10)

**Day 9: RevenueCat & Paywall**

- [x] Set up RevenueCat account and SDK
- [ ] Create offerings in RevenueCat dashboard
- [x] Premium entitlement check
- [x] Restore purchases
- [x] Paywall screen design
- [x] Free tier: 3 active goals
- [x] Premium: Unlimited goals

**Day 10: Settings & Polish**

- [ ] Settings screen (account, notifications, subscription)
  - [x] AI behavior setting (append vs replace existing actions)
  - [ ] More settings stuff
- [ ] Sign out / delete account
- [ ] Empty states with encouraging messages
- [ ] Loading states and error handling
- [ ] UI/UX improvements
  - [ ] App UI/UX redesign
  - [ ] Dark mode polish (improve colors and contrast)
- [ ] Accessibility improvements

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

- 3 active goals
- 5 micro-actions per goal
- Basic progress tracking?
- Daily reminders

### Premium ($2.99/month or $17.99/year)

- Unlimited goals
- Unlimited micro-actions
- Detailed analytics?
- Priority support
- Custom reminder times

---

## Judging Criteria

| Criteria                   | Weight | Focus                                      |
| -------------------------- | ------ | ------------------------------------------ |
| **Audience Fit**           | 30%    | Does it solve Gabby's community's problem? |
| **User Experience**        | 25%    | Is it delightful and easy to use?          |
| **Monetization Potential** | 20%    | Is the business model viable?              |
| **Innovation**             | 15%    | Is the approach creative and fresh?        |
| **Technical Quality**      | 10%    | Does it work? Is it polished?              |

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

| Risk              | Mitigation                    |
| ----------------- | ----------------------------- |
| Time crunch       | Borrow heavily from FoodPilot |
| RevenueCat issues | Set up early, test on Day 14  |
| Scope creep       | Strict MVP, no AI features    |
| Platform issues   | Test on both Android and iOS  |

---

## Daily Schedule Template

| Time      | Activity              |
| --------- | --------------------- |
| Morning   | Code core feature     |
| Afternoon | Continue + test       |
| Evening   | Review, plan tomorrow |

---

## Next Steps (Day 1)

1. [ ] Copy core files from FoodPilot (theme, router, auth patterns)
2. [ ] Set up Firebase project (aspire)
3. [ ] Configure Firebase Auth
4. [ ] Set up RevenueCat account
5. [ ] Get basic app shell running with routing
6. [ ] Register on DevPost
