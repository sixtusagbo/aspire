# Pre-Submission Gaps & Action Items

Based on feedback from the Shipyard live tips session.

---

## Code Changes Needed

### 1. Free Trial on Paywall (HIGH PRIORITY)

**Current state:** Soft freemium (3 goals free, 5 actions free). No trial.
**Judges recommended:** Hard paywall with free trial.

**What to do:**
- Configure free trial period on Google Play subscription products (7-day trial recommended)
- Update paywall screen to display trial info from RevenueCat's `introductoryPrice`
- Show "Start 7-Day Free Trial" as primary CTA instead of "Subscribe"
- During trial, user gets full premium access
- After trial ends, subscription kicks in or user drops to free tier

**Why it matters:** Users experience the FULL app before deciding. First impression = premium experience. Much higher conversion than hitting a wall at 3 goals.

### 2. Paywall After Onboarding (HIGH PRIORITY)

**Current state:** Paywall only appears when user hits a limit (4th goal, 6th action).
**What to change:** Present free trial offer at the end of onboarding, after the user has set up their first goal and seen value.

**Flow:**
1. Welcome → Name → Goal Setup → Notifications
2. NEW: "Unlock Everything" step - show premium features + free trial CTA
3. User either starts trial or skips to free tier

**Why it matters:** This is "priming to pay." User has just created their first goal, they're excited, and now you show them what premium unlocks. With a free trial, the friction is near zero.

### 3. Play Store Link in Share Messages (MEDIUM PRIORITY)

**Current state:** Share messages include hashtags but no link to download the app.
**What to change:** Add the Play Store link to share messages.

**Example:**
```
I just completed my goal: Visit Japan! From dreaming to doing, one micro-action at a time.

Try Aspire: https://play.google.com/store/apps/details?id=<app_id>
#Aspire #PacksLight
```

**Why it matters:** Without a link, the viral loop is broken. Someone sees the share, thinks "cool", but can't find the app. With a link, they tap and download.

### 4. "Share App" Option in Settings (LOW PRIORITY)

Add a dedicated "Tell a Friend" or "Share Aspire" button in settings that shares a pre-written message with the Play Store link. Easy win for virality.

---

## Submission / Non-Code Items

### 5. Creator Monetization Pitch

The submission must explain how Gabby specifically benefits:
- Her audience (ambitious women 25-45) already spends on self-improvement (courses, coaching, planners)
- $2.99/mo is impulse pricing - less than a coffee
- Gabby's brand trust lowers the conversion barrier
- Revenue share model (RevenueCat tracks this)
- The app extends Gabby's brand beyond content into a daily-use product
- Retention via streaks = sustained subscriptions (low churn)
- Free trial → high conversion because users form habits during trial

### 6. Virality Narrative

Explain in submission:
- Celebration sharing creates organic social proof
- Hashtag strategy (#Aspire #PacksLight) ties back to Gabby's brand
- Streak milestones create recurring share moments (not just one-time)
- Play Store link in shares closes the viral loop
- The "ambitious women" positioning creates community identity

---

## Priority Order

1. Free trial configuration (RevenueCat + Google Play Console + paywall UI)
2. Paywall presentation after onboarding
3. Play Store link in share messages
4. Demo video (see demo_video_tips.md)
5. Written submission with monetization pitch
6. Share app option in settings (if time permits)
