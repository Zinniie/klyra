# Klyra — Fintech Wallet App

> A full-featured digital wallet built with Flutter, Firebase, and Stripe. Cross-platform iOS and Android.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Stripe](https://img.shields.io/badge/Stripe-635BFF?logo=stripe&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-Pattern-blue)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Overview

Klyra is a production-quality fintech wallet application demonstrating real-world Flutter development — BLoC state management, Clean Architecture, Firebase Auth, Firestore real-time sync, Stripe payment flows, and biometric authentication.

**Core features:**
- Peer-to-peer money transfers with real-time Firestore balance sync
- Card management via Stripe — add, remove, set default
- Stripe Payment Intent flow with full 3D Secure (3DS) support
- Biometric login (fingerprint / Face ID) with secure PIN fallback
- Transaction history with categories and timestamps
- Push notifications via Firebase Cloud Messaging
- Verified account badge and masked account number display

---

## Test Account

To explore the app without creating an account:

```
Email:    test@klyra.app
Password: Klyra2026@
```

---

## Screenshots

### Splash & Onboarding
![Splash](screenshots/splash.png)
![Onboarding](screenshots/onboarding.png)

### Authentication
![Login](screenshots/login.png)
![Register](screenshots/register.png)

### Home Dashboard
![Home](screenshots/home.png)

### Send Money Flow
![Send Step 2](screenshots/send_amount.png)
![Send Step 3](screenshots/send_review.png)

### Top Up & Cards
![Top Up](screenshots/top_up.png)
![Add Card](screenshots/add_card.png)

### Notifications
![Notifications](screenshots/notifications.png)

---

## Architecture

```
lib/
├── core/
│   ├── models/          # Domain models: KlyraUser, KlyraTransaction, KlyraCard
│   ├── theme/           # Colours, typography, spacing, ThemeData
│   ├── router/          # go_router with auth redirect guards
│   └── utils/           # Formatters, validators, extensions
│
├── features/
│   ├── auth/
│   │   ├── bloc/        # AuthBloc — email, biometric, PIN, register, sign out
│   │   ├── repository/  # AuthRepository — Firebase Auth + Firestore
│   │   └── screens/     # Splash, Onboarding, Login, Register, PIN, Biometric
│   │
│   ├── home/
│   │   ├── screens/     # HomeScreen, MainShell (bottom nav)
│   │   └── widgets/     # BalanceCard, QuickActions, HomeAppBar
│   │
│   ├── transactions/
│   │   ├── bloc/        # TransactionBloc
│   │   ├── repository/  # TransactionRepository — Firestore + Stripe
│   │   └── screens/     # SendMoney, TopUp, History, Detail
│   │
│   ├── cards/
│   │   ├── bloc/        # CardBloc
│   │   ├── repository/  # CardRepository — Stripe Payment Methods
│   │   └── screens/     # CardsScreen, AddCardScreen
│   │
│   └── profile/
│       ├── bloc/        # ProfileBloc
│       └── screens/     # Profile, Security Settings, Notifications
│
└── main.dart            # App entry — Firebase init, Stripe setup, BLoC providers
```

**Patterns used:**
- **BLoC** for all feature state management (flutter_bloc ^8.x)
- **Clean Architecture** — domain models, repositories, and UI fully separated
- **Repository Pattern** — all data access abstracted behind repository interfaces
- **go_router** for declarative routing with auth redirect guards

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x / Dart 3.x |
| State Management | flutter_bloc + equatable |
| Navigation | go_router |
| Auth | Firebase Auth + local_auth (biometric) |
| Database | Cloud Firestore |
| Payments | Stripe Flutter SDK (flutter_stripe) |
| Local Storage | Hive + flutter_secure_storage |
| Push Notifications | Firebase Cloud Messaging |
| Networking | Dio + interceptors |
| DI | get_it + injectable |
| Testing | flutter_test + bloc_test + mocktail |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.1.0`
- Dart SDK `>=3.1.0`
- Firebase project (Auth + Firestore + FCM enabled)
- Stripe account (test keys for development)
- Xcode (iOS) / Android Studio (Android)

### 1. Clone the repo

```bash
git clone https://github.com/Zinniie/klyra.git
cd klyra
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Generates `lib/firebase_options.dart` automatically.

### 4. Set Stripe key

```bash
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
```

### 5. Install iOS pods

```bash
cd ios && pod install && cd ..
```

### 6. Run

```bash
flutter run
```

---

## Key Features Deep-Dive

### Biometric Authentication

Layered auth strategy:
1. **Primary** — Email + password via Firebase Auth
2. **Session** — Biometric (fingerprint / Face ID) via `local_auth`
3. **Fallback** — 6-digit PIN stored encrypted via `flutter_secure_storage`
4. **Zero trust** — No plaintext credentials stored on device

### Stripe Payment Flow

Full Payment Intent lifecycle:
```
Client → Create PaymentIntent → Server → Stripe
Client ← client_secret ← Server
Client → confirmPayment() → Stripe
Client ← 3DS challenge (if required) ← Stripe
Webhook: payment_intent.succeeded → Update Firestore
```

### Real-time Balance Sync

```dart
Stream<KlyraUser?> userStream(String uid) {
  return _firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) => snap.exists ? KlyraUser.fromFirestore(snap) : null);
}
```

---

## Roadmap

- [ ] International transfers (multi-currency)
- [ ] Savings goals with automated top-up
- [ ] Split bill functionality
- [ ] Spending analytics with fl_chart
- [ ] Dark mode
- [ ] Scheduled / recurring transfers
- [ ] In-app KYC document upload

---

## Author

**Blessing Nnabugwu**
Mobile SDK Developer · Toronto, ON
[linkedin.com/in/blessingnnabugwu](https://linkedin.com/in/blessingnnabugwu) · [zinniie.github.io](https://zinniie.github.io)

---

## License

MIT License — see [LICENSE](LICENSE) for details.
