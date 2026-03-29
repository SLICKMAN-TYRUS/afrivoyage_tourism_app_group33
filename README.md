# AfriVoyage - Group 33 Final Project Submission
### African Leadership University - Mobile Application Development
**Submission Deadline:** March 29, 2026

**Repository:** https://github.com/SLICKMAN-TYRUS/afrivoyage_tourism_app_group33.git  
**License:** MIT License

---

## Group 33 Members and Contributions

| Role | Responsibility | Contribution |
|------|---------------|--------------|
| **Role 1** | Clean Architecture setup, GoRouter navigation, Material 3 theme, BLoC infrastructure | 20% |
| **Role 2** | Tourist UI (Login, Home, Booking, Impact screens), Widget testing | 20% |
| **Role 3** | Provider UI (Dashboard, Listings, Earnings), Provider BLoCs | 20% |
| **Role 4** | Firebase backend, Authentication (2 methods), Firestore CRUD, Security Rules, ERD | 20% |
| **Role 5** | QA, Integration testing, PDF documentation, Video production | 20% |

---

## Executive Summary

AfriVoyage is a mobile application developed for the Mobile Application Development course at African Leadership University. It addresses the digital divide in Rwanda's tourism sector by connecting tourists with local experience providers while ensuring fair revenue distribution.

**Key Features:**
- Mobile Money integration (MTN/Airtel) for Rwanda's mobile-first economy
- Offline-first functionality for rural connectivity
- Real-time safety alerts from national authorities
- Transparent impact tracking (92% revenue to providers, 8% platform fee)

---

## Technical Implementation

### Architecture: Clean Architecture (3 Layers)



lib/
├── core/                    # Constants, routes, errors
├── domain/                  # Entities, repository interfaces, use cases
├── data/                    # Firebase repositories, models
└── presentation/            # UI layer (screens + BLoCs)
├── tourist/             # Tourist journey (Login, Home, Booking)
└── provider/            # Provider journey (Dashboard, Listings)





### State Management: BLoC Pattern
- **Zero setState() usage** throughout application
- All state managed via Events → BLoCs → States
- Repository pattern for data layer abstraction

### Technology Stack
- **Frontend:** Flutter 3.x with Dart
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** flutter_bloc
- **Navigation:** go_router
- **Authentication:** Firebase Auth + Google Sign-In

---

## Features Implemented (Rubric Compliance)

### 1. Authentication (2 Methods Required)
**File:** `lib/data/repositories/auth_repository.dart`

**Method 1: Email/Password**
- Registration with validation
- Secure login
- Password reset capability

**Method 2: Google Sign-In**
- OAuth 2.0 integration
- One-tap authentication
- Automatic profile creation

### 2. CRUD Operations (Create, Read, Update, Delete)
All operations reflect immediately in Firebase Firestore.

**Create:**
- `BookingRepository.createBooking()` - Tourists create reservations
- `ExperienceRepository.createExperience()` - Providers create listings

**Read:**
- `getTouristBookings()` - Real-time stream of user bookings
- `getProviderBookings()` - Provider dashboard data
- `getExperiences()` - Browse with category filters

**Update:**
- `updateBookingStatus()` - Status changes (pending→confirmed→completed)
- `updateExperience()` - Edit listings, toggle availability

**Delete:**
- Soft deletes via status updates (cancelled bookings)
- `deleteExperience()` - Remove listings

### 3. Additional Requirements
- **Clean Architecture:** Strict separation of presentation/domain/data layers
- **BLoC Pattern:** No setState() used anywhere in codebase
- **Physical Device:** Application runs on Android/iOS devices (not web)
- **Firebase Security:** Rules deployed and active
- **Testing:** Unit tests + Widget tests passing

---

## Database Architecture and  ERD
### Visual ERD
The full, rubric-compliant Entity-Relationship Diagram (ERD) is included as an image:

**[docs/ERD_Diagram.png](docs/ERD_Diagram.png)**

This diagram clearly shows all entities, attributes, relationships, and cardinality as required by the project rubric.

### Firestore Collections

**1. users** (Tourists & Providers)
- PK: uid (Firebase Auth ID)
- Fields: role, email, phone, displayName, photoURL
- Provider sub-object: badges, bio, location, earnings, verificationStatus

**2. experiences** (Tour Listings)
- PK: Auto-generated ID
- FK: providerId → users.uid
- Fields: title, description, priceRWF, location (GeoPoint), category, images, isAvailable, verificationBadges, rating, reviewCount

**3. bookings** (Core CRUD Entity)
- PK: Auto-generated ID
- FKs: touristId, experienceId, providerId
- Fields: status (pending/confirmed/completed/cancelled), bookingDate, experienceDate, groupSize, totalPrice, paymentMethod, paymentStatus, offlineSyncStatus

**4. reviews** (Feedback)
- PK: Auto-generated ID
- FK: bookingId (1:1 relationship)
- Fields: rating (1-5), comment, photos, createdAt

**5. safety_alerts** (Emergency Notifications)
- Fields: type, severity, message, geoFence (array of GeoPoints), expiresAt

### Relationships (see ERD for visual)
- users (1) → experiences (N)  *(provider creates)*
- users (1) → bookings (N)  *(tourist books)*
- experiences (1) → bookings (N)  *(experience booked)*
- bookings (1) → reviews (1)  *(booking reviewed)*
- safety_alerts: standalone, admin broadcast

## Security Implementation

### Firestore Security Rules
Deployed to production with role-based access control:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId) { return request.auth.uid == userId; }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    match /experiences/{id} {
      allow read: if true;
      allow create: if isAuthenticated() && isProvider();
      allow update, delete: if isAuthenticated() && resource.data.providerId == request.auth.uid;
    }
    
    match /bookings/{id} {
      allow create: if isAuthenticated() && request.resource.data.touristId == request.auth.uid;
      allow read, update: if isAuthenticated() && 
        (resource.data.touristId == request.auth.uid || resource.data.providerId == request.auth.uid);
    }
    
    match /reviews/{id} {
      allow read: if true;
      allow create: if isAuthenticated() && request.resource.data.touristId == request.auth.uid;
    }
  }
}





Security Measures
Authentication required for all write operations
Users can only access their own booking data (bilateral access)
Providers can only modify their own listings
API keys excluded via .gitignore (google-services.json, firebase_options.dart)
Input validation on client and server sides
Testing
Unit Tests
File: test/unit/payment_repository_test.dart
Tests payment calculation logic (8% platform fee)
Tests zero amount handling
All tests passing
Widget Tests
Files:
test/widget/tourist/auth_widget_test.dart
test/widget/provider/dashboard_widget_test.dart
Coverage:
Login screen rendering and interaction
Authentication flow state changes
Provider dashboard components

---

## Quality Gates

- `flutter analyze`    # Must show: **No issues found**
- `flutter test`       # All tests passing
- `dart format .`      # Code formatted

---

## Setup Instructions

**Prerequisites:**
- Flutter SDK >= 3.0.0
- Android Studio or VS Code
- Firebase CLI

**Installation:**
```sh
git clone https://github.com/SLICKMAN-TYRUS/afrivoyage_tourism_app_group33.git
cd afrivoyage_tourism_app_group33


Install dependencies:

Firebase configuration (Role 4 has pre-configured):
Download google-services.json from Firebase Console
Place in android/app/
Run: flutterfire configure
Deploy security rules:


Deploy security rules:

firebase deploy --only firestore:rules --project afrivoyage-group33



Run application:

flutter run


flutter build apk --release


Important: Demo video shows app running on physical Android device as required (web builds receive zero marks).


Known Limitations and Future Work
Current Limitations
Payment Integration: Uses mock PaymentRepository simulating MTN Mobile Money with artificial delays. Production requires MTN/Airtel API partnerships and Bank of Rwanda regulatory approval.
Offline Sync: Relies on Firestore's last-write-wins policy for conflicts. Production would need Operational Transformation algorithms.
Verification: Manual badge assignment. Future: API integration with Rwanda Development Board for automatic verification.
Geofencing: Simple radius queries. Future: Polygonal geofencing for mountainous terrain precision.
Future Enhancements
USSD (*123#) interface for providers with feature phones
Blockchain verification badges to prevent impersonation fraud
AI-powered experience matching
Swahili voice navigation for accessibility
Academic Integrity Statement
We hereby declare that this submission is our own original work developed specifically for the Mobile Application Development course at African Leadership University.
Git Workflow:
Feature branches created for each role (role1/architecture, role2/tourist-ui, etc.)
All branches merged to develop for integration testing
Final merge to main for submission
Commit history shows steady progress with descriptive messages (feat:, fix:, test:, docs:)
Contribution Verification: Each team member contributed 20% as documented in the group contribution tracker. All external resources (Flutter documentation, Firebase guides, BLoC library) have been properly referenced.
Submission Checklist (Rubric Requirements)
[x] Clean Architecture with presentation/domain/data layers
[x] BLoC pattern used exclusively (zero setState)
[x] Two authentication methods (Email/Password + Google)
[x] CRUD operations (Create, Read, Update, Delete) with Firebase reflection
[x] ERD diagram included in docs/
[x] Firestore Security Rules deployed and documented
[x] Unit tests (1+) and Widget tests implemented and passing
[x] Git branching strategy with meaningful commits
[x] Physical device demonstration (no web)
[x] PDF report with database architecture and security explanation
[x] Demo video (10-15 minutes) showing all features
[x] Comprehensive README (this document)
[x] flutter analyze returns zero warnings
[x] dart format applied to all files
African Leadership University
Mobile Application Development - Final Project
Group 33
March 29, 2026

