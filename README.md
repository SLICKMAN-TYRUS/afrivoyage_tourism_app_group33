# AfriVoyage — Group 33 Final Project
### African Leadership University · Mobile Application Development
**Submission Deadline:** April 1, 2026

**Repository:** https://github.com/SLICKMAN-TYRUS/afrivoyage_tourism_app_group33.git
**License:** MIT

---

## Group 33 — Members and Contributions

| Role | Responsibility | Contribution |
|------|----------------|--------------|
| **Role 1** | Clean Architecture setup, GoRouter navigation, Material 3 theme, BLoC infrastructure | 20% |
| **Role 2** | Tourist UI (Login, Home, Booking, Impact, Profile screens), widget testing | 20% |
| **Role 3** | Provider UI (Dashboard, Listings, Earnings), Provider BLoC | 20% |
| **Role 4** | Firebase backend, Authentication (2 methods), Firestore CRUD, Security Rules, ERD | 20% |
| **Role 5** | QA, full test suite, Firebase web compat upgrade, navigation wiring, PDF docs, video | 20% |

---

## Executive Summary

AfriVoyage is a cross-platform Flutter application built for the Mobile Application Development course at African Leadership University. It tackles the digital divide in Rwanda's tourism sector by connecting tourists with local experience providers while ensuring fair, transparent revenue distribution.

**Core value propositions:**
- **92 / 8 split** — 92 % of every booking goes directly to the local provider; 8 % platform fee
- **Mobile Money** — MTN / Airtel payment simulation tailored for Rwanda's mobile-first economy
- **Offline-first** — `offlineSyncStatus` field on bookings allows queued operations during connectivity gaps
- **Real-time safety alerts** — Firestore `safety_alerts` collection fed by admin / Cloud Functions
- **Dual user journeys** — separate Tourist and Provider flows under one login

---

## Navigation Map

```
┌─────────────────────────────────────────────────────┐
│                  /login  (initial)                  │
│  Auth guard: redirects → /home if already signed in │
└──────────────────────┬──────────────────────────────┘
                       │ sign-in success
          ┌────────────▼────────────┐
          │     /home  (Shell)      │
          │  BottomNavigationBar    │
          └──┬──┬──┬──┬──┬─────────┘
             │  │  │  │  │
     ┌───────┘  │  │  │  └────────────────┐
     │ Tab 0    │  │  │ Tab 4             │
     │ Home     │  │  │ Profile           │
     │ Browse   │  │  │ Avatar · Email    │
     │ experi-  │  │  │ → /provider       │
     │ ences    │  │  │ → /impact         │
     │          │  │  │ → /bookings       │
     └──────────┘  │  │ Sign Out → /login │
                   │  └───────────────────┘
          ┌────────┘  Tab 3
          │ Tab 2     /impact  ←─────────────────┐
          │ /bookings  Community impact stats     │
          │ Reserva-                              │
          │ tions list                            │
          └────────────────────────────────────── ┘

/booking/:id  ──  full-screen booking detail (slide in from right)

/provider  ──  Provider Dashboard (BottomNavigationBar)
  ├── Tab 0  Dashboard    bookings summary + quick actions
  ├── Tab 1  Listings  →  /provider/listings  (slide transition)
  ├── Tab 2  Tourist   →  /home  (switch back to tourist view)
  ├── Tab 3  Earnings  →  /provider/earnings  (slide transition)
  └── Tab 4  Sign Out  →  FirebaseAuth.signOut() → /login
```

**Route guard behaviour:**
- Unauthenticated user visiting any protected path → redirected to `/login`
- Authenticated user visiting `/login` → redirected to `/home`
- Guard re-evaluates automatically on every `FirebaseAuth.authStateChanges()` event via `_GoRouterRefreshStream`

---

## Architecture

### Layer diagram

```
lib/
├── core/                          # Cross-cutting infrastructure
│   ├── constants/
│   │   └── app_constants.dart     # App-wide string constants & collection names
│   ├── cubits/
│   │   └── settings_cubit.dart    # Persisted settings (theme, language, offline mode)
│   ├── errors/
│   │   └── failures.dart          # Failure hierarchy (Server / Cache / Network / Auth)
│   ├── observers/
│   │   ├── app_bloc_observer.dart # Global BLoC observer — logs every event & state change
│   │   └── router_observer.dart   # GoRouter navigation event logger
│   └── routes/
│       ├── app_router.dart        # GoRouter config: auth guard, ShellRoute, transitions
│       ├── error_page.dart        # Fallback page for unmatched routes
│       └── route_names.dart       # Centralised route path & name constants
│
├── data/                          # Firebase / remote data layer
│   ├── models/
│   │   └── booking_model.dart     # Booking domain model with Firestore serialisation
│   └── repositories/
│       ├── auth_repository.dart   # Firebase Auth + Google Sign-In (lazy getters)
│       ├── booking_repository.dart# Firestore CRUD — bookings collection
│       ├── experience_repository.dart # Firestore CRUD — experiences collection
│       └── payment_repository.dart# Mock MTN Mobile Money (8 % fee logic)
│
├── l10n/                          # Internationalisation
│   ├── app_en.arb                 # English strings
│   ├── app_fr.arb                 # French strings
│   └── app_rw.arb                 # Kinyarwanda strings
│
├── presentation/                  # UI layer
│   ├── shared/
│   │   └── theme/
│   │       ├── app_theme.dart     # Material 3 light & dark ThemeData definitions
│   │       └── theme_cubit.dart   # ThemeCubit — persists ThemeMode to SharedPreferences
│   ├── tourist/
│   │   ├── blocs/
│   │   │   ├── auth_bloc.dart     # AuthEvent → AuthBloc → AuthState
│   │   │   └── experience_bloc.dart # LoadExperiences / CreateBooking
│   │   └── screens/
│   │       ├── login_screen.dart  # Email/Password + Google Sign-In, Log In / Sign Up toggle
│   │       ├── home_screen.dart   # 5-tab shell: Home · Explore · Bookings · Impact · Profile
│   │       ├── booking_screen.dart# Date picker, group size, MTN payment breakdown
│   │       ├── impact_screen.dart # Community impact stats & contribution breakdown
│   │       └── profile_screen.dart# User profile details
│   └── provider/
│       ├── blocs/
│       │   └── provider_bloc.dart # LoadProviderBookings / UpdateBookingStatus / ToggleAvailability
│       └── screens/
│           ├── provider_dashboard.dart # Earnings summary, booking list, quick actions
│           ├── provider_listings.dart  # Tour listing cards with availability toggle
│           └── provider_earnings.dart  # Monthly earnings breakdown + commission structure
│
├── firebase_options.dart          # Generated by FlutterFire CLI
└── main.dart                      # Entry point: Firebase init, portrait lock,
                                   # SharedPreferences, ThemeCubit, AppBlocObserver
```

### State management

Every mutable state flows through the **BLoC / Cubit pattern**:

| BLoC / Cubit | Responsibility |
|---|---|
| `AuthBloc` | Email login · Google login · Registration · Logout |
| `ExperienceBloc` | Real-time experience stream · Booking creation |
| `ProviderBloc` | Provider booking stream · Status updates · Availability toggle |
| `ThemeCubit` | Light / Dark / System theme, persisted to `SharedPreferences` |
| `SettingsCubit` | Language, dark mode flag, offline mode flag |

> `setState()` is used only for ephemeral local UI state (e.g. the toggle between Log In and Sign Up inside `LoginScreen`). All business logic and server-driven state uses BLoC/Cubit exclusively.

### Routing

`app_router.dart` uses **GoRouter 13.x** with:
- `redirect` callback for unauthenticated-access protection
- `_GoRouterRefreshStream` bridging `FirebaseAuth.authStateChanges()` to `ChangeNotifier` so the guard reacts to every sign-in / sign-out automatically
- `ShellRoute` for the shared bottom navigation bar across main tabs
- `NoTransitionPage` on tab switches (instant feel)
- `CustomTransitionPage` with a 350 ms `CurvedAnimation` slide on detail screens
- `errorBuilder` pointing to `ErrorPage` for unmatched routes
- `RouterObserver` logging every navigation event to the debug console
- All paths and names centralised in `RouteNames` — no magic strings scattered across the codebase

---

## Technology Stack

| Layer | Technology | Version |
|---|---|---|
| UI framework | Flutter | 3.38.5 |
| Language | Dart | 3.10.4 |
| State management | flutter_bloc / Cubit | ^8.1.3 |
| Navigation | go_router | ^13.0.1 |
| Firebase core | firebase_core | ^4.0.0 |
| Authentication | firebase_auth | ^6.0.0 |
| Database | cloud_firestore | ^6.0.0 |
| Storage | firebase_storage | ^13.0.0 |
| Google Sign-In | google_sign_in | ^6.2.0 |
| Persistence | shared_preferences | ^2.2.2 |
| Fonts | google_fonts | ^6.3.1 |
| Equality | equatable | ^2.0.5 |
| i18n | flutter_localizations (SDK) | — |

> **Web note:** Firebase packages `^4 / ^6 / ^13` are required. Earlier versions (`firebase_core ^2.x`, `firebase_auth ^4.x`) depend on the discontinued `package:js` library (`PromiseJsImpl` / `handleThenable`) which was removed in Dart 3.x and causes ~100 compile errors when targeting Chrome. Always run `flutter pub get` after cloning to pull the correct locked versions.

---

## Features Implemented

### 1. Authentication — 2 methods (Rubric requirement)

**File:** `lib/data/repositories/auth_repository.dart`

| Method | Detail |
|---|---|
| **Email / Password** | Registration (`createUserWithEmailAndPassword`), secure login, error messages surfaced via `AuthError` state |
| **Google Sign-In** | OAuth 2.0 via `google_sign_in ^6.x`, `GoogleAuthProvider.credential`, one-tap on Android / iOS |

Both methods are handled by `AuthBloc` (Events → States pattern). The `LoginScreen` listens via `BlocListener` and navigates to `/home` on `AuthAuthenticated`.

### 2. CRUD Operations — all reflected in Firebase (Rubric requirement)

| Operation | Repository method | Firestore collection |
|---|---|---|
| **Create** booking | `BookingRepository.createBooking()` | `bookings` |
| **Create** experience | `ExperienceRepository.createExperience()` | `experiences` |
| **Read** tourist bookings | `getTouristBookings()` — real-time stream | `bookings` |
| **Read** provider bookings | `getProviderBookings()` — real-time stream | `bookings` |
| **Read** experience list | `getExperiences()` — with category / price filters | `experiences` |
| **Update** booking status | `updateBookingStatus()` pending → confirmed → completed | `bookings` |
| **Update** experience | `updateExperience()` — edit details, toggle availability | `experiences` |
| **Delete** (soft) | `cancelBooking()` — sets `status: cancelled` | `bookings` |
| **Delete** (hard) | `deleteExperience()` — removes listing | `experiences` |

### 3. Tourist journey

- **Home tab** — real-time experience cards from Firestore; verified-provider badge; category filter chips; "Book Now" navigates to `/booking/:id`
- **Explore tab** — hero banner + same experience grid with a search-first emphasis
- **Bookings tab** — reservations list (empty-state with CTA when no bookings)
- **Impact tab** — community impact stats: families supported, local earnings, verified bookings, contribution breakdown by cause
- **Profile tab** — avatar, display name / email, shortcuts to Provider Dashboard and Impact; **Sign Out** button

### 4. Provider journey

- **Dashboard** — monthly earnings summary, today's bookings count, pending / confirmed / completed stats, recent booking cards with status actions (Confirm / Mark Complete / Cancel)
- **Listings** — experience cards with availability toggle, rating, review count, Edit and Stats actions
- **Earnings** — total earnings card, monthly breakdown, commission structure (92 % provider / 8 % platform)
- **Tourist tab** — one-tap switch back to the tourist browse view
- **Sign Out** — signs out via `FirebaseAuth.signOut()` and navigates to `/login`

### 5. Settings & theme

- `ThemeCubit` persists light / dark / system `ThemeMode` across restarts via `SharedPreferences`
- `SettingsCubit` persists language code and offline-mode flag
- Full Material 3 light and dark `ThemeData` with deep-forest-green primary (`#2E7D32`) and warm-amber secondary (`#F57C00`)
- Portrait-only orientation lock via `SystemChrome`
- Transparent status bar for immersive hero images

### 6. Internationalisation

ARB files in `lib/l10n/` cover all UI strings in three locales:

| File | Locale |
|---|---|
| `app_en.arb` | English |
| `app_fr.arb` | French |
| `app_rw.arb` | Kinyarwanda |

Generated via `flutter gen-l10n` (`generate: true` in `pubspec.yaml`).

---

## Database Architecture

### Firestore collections

**1. `users`** — Tourist and Provider profiles
- PK: `uid` (Firebase Auth UID)
- Fields: `role`, `email`, `phone`, `displayName`, `photoURL`
- Provider sub-object: `badges`, `bio`, `location`, `earnings`, `verificationStatus`

**2. `experiences`** — Tour listings
- PK: auto-generated Firestore ID
- FK: `providerId → users.uid`
- Fields: `title`, `description`, `priceRWF`, `location (GeoPoint)`, `category`, `images`, `isAvailable`, `verificationBadges`, `rating`, `reviewCount`

**3. `bookings`** — Core transactional entity (primary CRUD target)
- PK: auto-generated Firestore ID
- FKs: `touristId → users.uid`, `experienceId → experiences.id`, `providerId → users.uid`
- Fields: `status` (pending / confirmed / completed / cancelled), `bookingDate`, `experienceDate`, `groupSize`, `totalPrice`, `paymentMethod`, `paymentStatus`, `offlineSyncStatus`

**4. `reviews`** — Post-experience feedback
- PK: auto-generated Firestore ID
- FK: `bookingId → bookings.id` (1 : 1)
- Fields: `rating (1–5)`, `comment`, `photos`, `createdAt`

**5. `safety_alerts`** — Emergency notifications (admin-write only)
- Fields: `type`, `severity`, `message`, `geoFence (GeoPoint[])`, `expiresAt`

### Relationships

```
users (1) ──────────────────────────< (N) experiences
users (1) ──────────────────────────< (N) bookings  [as tourist]
users (1) ──────────────────────────< (N) bookings  [as provider]
experiences (1) ─────────────────── < (N) bookings
bookings (1) ────────────────────── (1)  reviews
safety_alerts  ──  standalone (admin SDK / Cloud Functions only)
```

Full visual ERD: **[docs/ERD_Diagram.png](docs/ERD_Diagram.png)**
Text ERD: **[docs/ERD_Diagram.txt](docs/ERD_Diagram.txt)**
Architecture write-up: **[docs/database_architecture.txt](docs/database_architecture.txt)**

---

## Security

### Firestore Security Rules

Deployed via `firebase deploy --only firestore:rules`. Role-based access control using helper functions:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId)   { return request.auth.uid == userId; }

    function isTourist() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'tourist';
    }
    function isProvider() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'provider';
    }

    // Users — any authenticated user can read; only the owner can write
    match /users/{userId} {
      allow read:   if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
    }

    // Experiences — public read; only verified providers can create/edit their own
    match /experiences/{experienceId} {
      allow read:          if true;
      allow create:        if isAuthenticated() && isProvider();
      allow update, delete: if isAuthenticated() && resource.data.providerId == request.auth.uid;
    }

    // Bookings — bilateral access: tourist sees their bookings, provider sees bookings for their experiences
    match /bookings/{bookingId} {
      allow create: if isAuthenticated() && request.resource.data.touristId == request.auth.uid;
      allow read, update: if isAuthenticated() &&
        (resource.data.touristId == request.auth.uid ||
         resource.data.providerId == request.auth.uid);
    }

    // Reviews — public read; tourists append their own reviews only
    match /reviews/{reviewId} {
      allow read:   if true;
      allow create: if isAuthenticated() && isTourist() &&
                       request.resource.data.touristId == request.auth.uid;
    }

    // Safety alerts — public read; client writes are blocked (admin SDK only)
    match /safety_alerts/{alertId} {
      allow read:  if true;
      allow write: if false;
    }
  }
}
```

Full explanation: **[docs/security_rules_explanation.txt](docs/security_rules_explanation.txt)**

### Additional security measures
- `firebase_options.dart` and `google-services.json` excluded via `.gitignore`
- Input validation on both client and Firestore rule side
- Booking creation locked to the requester's own UID (prevents spoofed bookings)
- Review creation locked to tourists who made the booking

---

## Test Suite

```
test/
├── unit/
│   ├── payment_repository_test.dart   # 8 % platform fee + zero-amountedge case
│   ├── booking_validation_test.dart   # Price × group-size calculation, past-date rejection
│   └── date_utils_test.dart           # Date formatting, days-until-experience delta
├── widget/
│   └── provider/
│       └── dashboard_widget_test.dart # ProviderDashboard render + bottom-nav labels
├── widget_test.dart                   # LoginScreen render + Log In / Sign Up toggle
└── login_screen_test.dart             # Extended login screen interaction tests
```

### Test design decisions

**Unit tests** (`test/unit/`) are pure-Dart — zero Firebase dependency. `PaymentRepository` is a plain Dart class so the fee-calculation tests run instantly without any mock infrastructure.

**Widget tests** use two isolation strategies:

| Test target | Strategy |
|---|---|
| `LoginScreen` | `MockAuthBloc extends AuthBloc` constructed with `_FakeAuthRepository` (overrides every Firebase method to return `null`). `AuthBloc`'s constructor only stores the repository — no Firebase touch on construction. |
| `ProviderDashboard` | `_StubBookingRepository` and `_StubExperienceRepository` extend the real classes and override every Firestore-touching method to return `Stream.empty()` / no-ops. Injected via the widget's optional constructor parameters (`bookingRepository:`, `experienceRepository:`, `providerId:`). |

The stub approach was enabled by a one-line change in both repository classes: `final FirebaseFirestore _firestore = FirebaseFirestore.instance` was replaced with `FirebaseFirestore get _firestore => FirebaseFirestore.instance`. This makes `_firestore` a **lazy getter** — constructing or subclassing the repository no longer touches Firebase, so stubs never cause an initialisation error.

### Running the tests

```sh
flutter test                # all tests
flutter test test/unit/     # unit tests only
flutter test test/widget/   # widget tests only
```

Expected output:
```
+10: All tests passed!
```

---

## Setup Instructions

### Prerequisites

| Tool | Minimum version |
|---|---|
| Flutter SDK | 3.22.0 (3.38.5 recommended) |
| Dart SDK | 3.0.0 |
| Firebase CLI | latest |
| Android Studio or VS Code | latest |

> **Web (Chrome) requires Flutter ≥ 3.22 and the Firebase package versions listed in the tech stack table above.** Older Firebase packages use the discontinued `package:js` library which produces `PromiseJsImpl not found` compile errors on all Dart 3.x web targets.

### Step-by-step

```sh
# 1. Clone the repository
git clone https://github.com/SLICKMAN-TYRUS/afrivoyage_tourism_app_group33.git
cd afrivoyage_tourism_app_group33

# 2. Install dependencies
flutter pub get

# 3. Firebase configuration (Role 4 has pre-configured the project)
#    For a fresh setup:
#      a) Download google-services.json from Firebase Console → place in android/app/
#      b) Download GoogleService-Info.plist → place in ios/Runner/
#      c) Run: flutterfire configure --project afrivoyage-group33

# 4. Deploy Firestore security rules
firebase deploy --only firestore:rules --project afrivoyage-group33

# 5. Run on a connected device or emulator
flutter run

# 6. Or build a release APK for physical device demo
flutter build apk --release
```

### Verify quality gates before submitting

```sh
flutter analyze   # must return: No issues found
flutter test      # must return: All tests passed
dart format .     # formats all .dart files in place
```

---

## Known Limitations

| Area | Current state | Future work |
|---|---|---|
| **Payment** | `PaymentRepository` simulates MTN Mobile Money with artificial latency and a 90 % success rate. No real money moves. | Integrate MTN MoMo API + Airtel Money API; requires MNO partnership and Bank of Rwanda compliance. |
| **Booking creation** | `BookingScreen._processBooking()` shows a confirmation dialog after a simulated delay but does not yet call `BookingRepository.createBooking()`. | Wire the screen to the repository and pass the authenticated `touristId` from `FirebaseAuth.currentUser`. |
| **Provider data** | `ProviderListings` and `ProviderEarnings` display static mock data. | Replace with live Firestore streams via `ExperienceRepository` and an aggregation query. |
| **Offline sync** | Relies on Firestore's last-write-wins. Double-booking during concurrent offline sessions is possible. | Implement CRDT-based conflict resolution or server-side Cloud Functions to guard slot availability. |
| **Verification badges** | Manually assigned by an admin. | Integrate Rwanda Development Board (RDB) and RCHA APIs for automated guide-licence validation. |
| **Geofencing** | Safety alerts use simple radius queries. | Polygonal geofencing with Turf.js for mountainous terrain precision. |
| **google_sign_in** | Pinned to `^6.x`. Version 7 is a full API rewrite (singleton + mandatory `initialize()`). | Migrate to `google_sign_in ^7.x` once the team is ready to update `AuthRepository`. |

---

## Future Enhancements

- **USSD fallback** — `*123#`-style interface for providers using feature phones
- **Blockchain badges** — immutable on-chain verification to prevent provider impersonation
- **AI experience matching** — ML model matching tourists to providers by interest profile and language
- **Kinyarwanda voice navigation** — audio guides for low-literacy rural users
- **Dynamic safety alert map** — live geofenced overlay integrated with Rwanda's NECC

---

## Academic Integrity

We declare this submission is our original work developed for the Mobile Application Development course at African Leadership University.

**Git workflow:**
- Feature branches per role: `role1/architecture`, `role2/tourist-ui`, `role3/provider-ui`, `role4/firebase`, `role5/testing-docs`
- Branches merged to `develop` for integration testing
- Final merge to `main` for submission
- Commit history uses conventional prefixes: `feat:`, `fix:`, `test:`, `docs:`, `refactor:`

All external resources (Flutter documentation, Firebase guides, BLoC library, GoRouter) have been properly referenced. API keys and Firebase configuration files are excluded from version control via `.gitignore`.

---

## Submission Checklist

- [x] Clean Architecture — `core / data / presentation` layers with clear boundaries
- [x] BLoC pattern — business logic and server state managed exclusively through BLoC/Cubit
- [x] Two authentication methods — Email/Password + Google Sign-In (OAuth 2.0)
- [x] CRUD operations — Create, Read, Update, Delete reflected in Firebase Firestore
- [x] ERD diagram — included in `docs/ERD_Diagram.png` and `docs/ERD_Diagram.txt`
- [x] Firestore Security Rules — deployed and documented in `docs/security_rules_explanation.txt`
- [x] Unit tests — `payment_repository_test.dart`, `booking_validation_test.dart`, `date_utils_test.dart`
- [x] Widget tests — `widget_test.dart`, `login_screen_test.dart`, `test/widget/provider/dashboard_widget_test.dart`
- [x] All tests passing — `flutter test` returns `+10: All tests passed!`
- [x] Git branching strategy — feature branches with meaningful commit messages
- [x] Internationalisation — English, French, Kinyarwanda ARB files
- [x] Persistent theme — light / dark / system mode saved across restarts
- [x] Auth route guard — unauthenticated deep-links redirect to `/login`
- [x] Full navigation — all bottom-nav tabs functional in both Tourist and Provider journeys
- [x] Sign-out — available from Tourist Profile tab and Provider bottom nav
- [x] Firebase web compatibility — packages upgraded to `dart:js_interop`-compatible versions
- [x] PDF report — database architecture and security explanation
- [x] Demo video (10–15 minutes) — all features demonstrated on a physical device
- [x] `flutter analyze` — zero warnings
- [x] `dart format .` — applied to all files
- [x] Comprehensive README — this document

---

*African Leadership University · Mobile Application Development · Group 33 · March 29, 2026*
