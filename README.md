# Aspire

From dreaming to doing - a goal achievement app for ambitious women.

Built for [Gabby Beckford](https://packslight.com) (@PacksLight) as part of the [RevenueCat Shipyard 2026](https://www.revenuecat.com/shipyard/) hackathon.

## Features

- **Smart Goal Setting** - Create meaningful goals with clear outcomes
- **AI-Powered Micro-Actions** - Break down goals into small, achievable daily actions
- **Streak Tracking** - Build momentum with daily progress tracking
- **Celebrations** - Confetti and haptic feedback to celebrate wins

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Firebase Auth** - Email/password and Google Sign-In
- **Cloud Firestore** - Real-time database
- **Firebase Functions** - AI-powered action generation (OpenAI)
- **RevenueCat** - Subscription management

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Firebase CLI
- A Firebase project (see [docs/SETUP.md](docs/SETUP.md))

### Installation

```bash
# Clone the repo
git clone https://github.com/sixtusagbo/aspire.git
cd aspire

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Configuration

See [docs/SETUP.md](docs/SETUP.md) for detailed Firebase and RevenueCat setup instructions.

## Project Structure

```
lib/
├── core/           # Theme, utils, shared widgets
├── features/       # Feature modules (screens + widgets)
├── models/         # Data models
├── services/       # Firebase, RevenueCat, notifications
└── data/           # Static data
```
