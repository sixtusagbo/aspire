# Changelog

All notable changes to Aspire will be documented in this file.

## [0.1.10] - 2026-02-10

### Changed
- Tuned celebration confetti intensity for better visual balance

## [0.1.9] - 2026-02-10

### Fixed
- Account deletion now fully signs out of Google OAuth

## [0.1.8] - 2026-02-10

### Added
- Theme mode selection in settings (Light, Dark, Auto) with inline segmented control
- Free trial support on paywall with post-onboarding display
- Google Play download CTA in share messages
- Full-screen non-dismissible loading for account deletion

### Changed
- Redesigned settings screen with grouped card layout and profile header
- All loading indicators and switches now use platform-adaptive variants
- Reordered settings items for better UX flow

### Fixed
- X logo visibility in dark mode

## [0.1.7] - 2026-02-09

### Added
- Swipe-to-reveal edit/delete buttons for micro-actions
- First-time swipe hint tooltip (stored locally, shows once)
- Next milestone indicator in streak section with scrollable milestones up to 20,000 days
- Social proof badge on paywall ("Join 450K+ ambitious women")
- Passport stamp visual for completed goals
- Loading state on "New Goal" button
- Accessibility tooltips on drag handles and password visibility toggle

### Changed
- Redesigned paywall pricing cards with per-month price display
- Show "None" for 0-day streaks instead of "0 day"
- Wider swipe-to-reveal actions (40% width for 2 buttons)
- Better currency formatting using NumberFormat.simpleCurrency

### Fixed
- Daily reminder toggle disabled when system notifications are off

## [0.1.6] - 2026-02-08

### Added
- Level up celebration with confetti and dialog
- Terms of Service and Privacy Policy links in settings

### Changed
- Level titles now more aspirational: Dreamer, Go-Getter, Trailblazer, Maverick, Visionary, Legend

### Fixed
- XP level calculation now correctly shows progress
- Notification prompt flow in onboarding and home screen
- Settings notification toggle now opens system settings
- Goal form keyboard dismisses after applying template

## [0.1.5] - 2026-01-30

### Added
- Tip of the Day card on home screen with Gabby quotes
- Social sharing for streaks and goal completions
- Goal templates to help users get started
- Celebration sound effect for goal completion
- Custom categories (premium) - create your own goal categories
- Manage custom categories in Settings (edit/rename/delete)
- Personalized greeting on home screen
- Edit account name in Settings

### Improved
- Accessibility: reduced motion support for animations
- Accessibility: improved contrast ratios (WCAG AA)
- Accessibility: tooltips on icon buttons

## [0.1.4] - 2026-01-29

### Changed
- UI/UX overhaul with Packslight.com-inspired design
- Dark mode now uses warm purple-black tones
- Improved theme consistency across all screens

### Fixed
- Scheduled notifications now fire at correct local time (timezone fix)
- Notifications persist after device reboot

## [0.1.3] - 2026-01-27

### Added
- Custom reminders per goal (premium feature)
- Premium status indicator in settings
- "You're Premium" screen for existing premium users

### Changed
- Paywall now shows premium status for subscribers

## [0.1.2] - 2026-01-27

### Added
- AI considers existing actions and suggests append or replace mode
- Action limits enforced for both AI-generated and manual actions (5 free, 10 premium)

### Changed
- Daily reminder now enabled by default
- Removed "Detailed Analytics" from premium features

### Fixed
- Reminder settings now sync correctly between onboarding and settings

## [0.1.1] - 2025-01-27

### Added
- RevenueCat integration for premium subscriptions
- Paywall screen with monthly ($2.99) and yearly ($17.99) options

## [0.1.0] - 2025-01-26

### Added
- Initial MVP release
- Goal creation with AI-generated micro-actions
- Daily action tracking with streaks
- Firebase authentication (Email + Google Sign-In)
- Firestore data persistence
- Basic settings screen
