# PROJECT_ANALYSIS.md

> **Generated:** July 21, 2026  
> **Project:** SportsEco (Sports Ecosystem Platform - Pune Pilot)  
> **Version:** 1.0.0+1

---

## 1. Project Overview

### What This App Does

SportsEco is a **comprehensive sports ecosystem platform** designed to connect all participants in the grassroots and semi-professional sports landscape in India. It serves as a unified marketplace and management layer for:

- **Players** (athletes, typically 8-25 years old) — discover coaches, track performance, upload videos for AI analysis, join squad goals, earn gamification points/achievements
- **Coaches** — find students, manage sessions, track earnings, build reputation, apply for academy jobs
- **Academies** — manage batches, recruit coaches, run advertising campaigns, post job listings
- **Parents** — manage linked child players, track their progress, discover and book coaches
- **Admins** — platform management, venue CRUD, user oversight, coupon/task management

### Target Users

- **Primary Market:** Pune, India (pilot city)
- **Primary Demographic:** Young athletes (8-25) and their parents
- **Secondary:** Coaches, sports academies, venue operators
- **Currency/Numbering:** Indian Rupees (₹), Indian numbering system (Cr/L/K)

### Main Features

| Feature Area | Description |
|---|---|
| Auth & Roles | Email/password + Google sign-in, 5 user roles, role-based routing |
| Coach Discovery | Search/browse coaches by sport, city, specialization |
| Venue Discovery | Search/browse venues with amenities, sports, ratings |
| Session Management | Create, book, schedule coaching sessions |
| Contracts | Digital contract creation with escrow, fee calculation, signing |
| Chat | Real-time messaging between any users |
| Video Analysis | Upload training videos for AI-powered form analysis |
| Squad Goals | Team-based athletic goal tracking |
| Community Feed | Social posting with likes, comments, shares |
| Gamification | 6 levels (Rookie→Mythic), 5 ranks (Bronze→Diamond), 6 achievements |
| Performance Tracking | Player metrics logging and visualization |
| Job Board | Academy job postings, coach applications |
| Admin Panel | User/venue/coupon management, revenue tracking, task management |

---

## 2. Technology Stack

| Layer | Technology | Version/Details |
|---|---|---|
| **Flutter** | Dart SDK | `^3.11.1` |
| **State Management** | Riverpod | `flutter_riverpod: ^3.3.1`, `riverpod_annotation: ^4.0.2`, `riverpod_generator: ^4.0.3` |
| **Routing** | go_router | `^17.3.0` |
| **Backend/Database** | Firebase Firestore | `cloud_firestore: ^6.1.3` |
| **Authentication** | Firebase Auth | `firebase_auth: ^6.2.0` (email/password + Google) |
| **File Storage** | Firebase Storage | `firebase_storage: ^13.4.2` |
| **Push Notifications** | Firebase Messaging | `firebase_messaging: ^16.0.4` (declared, not deeply integrated) |
| **Local Notifications** | flutter_local_notifications | `^22.0.0` (declared, not deeply integrated) |
| **Maps** | Google Maps Flutter | `^2.12.0` (declared, partially integrated) |
| **Location** | geolocator + geocoding | `^14.0.2` / `^4.0.0` |
| **Charts** | fl_chart | `^1.2.0` |
| **Fonts** | Google Fonts | `^8.1.0` (Poppins + Inter) |
| **Image Loading** | cached_network_image | `^3.4.1` |
| **Animations** | flutter_animate | `^4.5.2` |
| **Loading States** | shimmer | `^3.0.0` |
| **SVG** | flutter_svg | `^2.0.17` |
| **Timeline** | timeline_tile | `^2.0.0` |
| **Lottie** | lottie | `^3.3.1` |
| **Badges** | badges | `^3.1.2` |
| **UUID** | uuid | `^4.5.1` |
| **Date/Time** | intl | `^0.20.2` |
| **Persistence** | shared_preferences | `^2.5.5` (theme persistence) |
| **Image Picker** | image_picker | `^1.1.2` |
| **URL Launching** | url_launcher | `^6.3.1` |
| **Device Preview** | device_preview | `^1.2.0` |
| **Linting** | flutter_lints | `^6.0.0` |
| **Build Runner** | build_runner | `^2.4.14` |

---

## 3. Folder Structure Explanation

```
Sports_App/
├── android/                  # Android platform project
├── ios/                      # iOS platform project
├── macos/                    # macOS platform project
├── web/                      # Web platform project
├── windows/                  # Windows platform project
├── assets/                   # Static assets (9 categories)
│   ├── animations/           # Animation files
│   ├── avatars/              # Default avatar images
│   ├── backgrounds/          # Background images/gradients
│   ├── empty/                # Empty state illustrations
│   ├── icons/                # Custom icons
│   ├── illustrations/        # Illustration images
│   ├── images/               # General images
│   ├── logos/                # App/partner logos
│   └── lottie/               # Lottie animation JSON files
├── docs/                     # Product documentation (25 files)
│   ├── 00_Vision.md          # Product vision & philosophy
│   ├── 01_PRODUCT_VISION.md  # Detailed product vision
│   ├── 02_USER_ROLES.md      # Complete role architecture (458 lines)
│   ├── 03_FEATURE_MAP.md     # Feature inventory (300+ lines)
│   ├── 07_SCREEN_INVENTORY.md# Screen audit (223 lines)
│   ├── 10_PHASE_ROADMAP.md   # Phased rollout plan (729 lines)
│   ├── 08_GAMIFICATION_SYSTEM.md
│   ├── 09_AI_FEATURES.md
│   └── audits/               # Audit reports
├── prompts/                  # Development prompts
├── test/                     # Test directory (exists but empty/minimal)
├── lib/                      # Main Dart source code
│   ├── main.dart             # App entry point (Firebase init, ProviderScope)
│   ├── app.dart              # MaterialApp.router with theme + go_router
│   ├── firebase_options.dart # FlutterFire CLI generated config
│   ├── core/                 # Cross-cutting concerns (17 files)
│   │   ├── constants/        # App-wide static values (app_constants.dart)
│   │   ├── routing/          # GoRouter setup + auth guards (app_router.dart)
│   │   ├── theme/            # Colors, typography, dimensions, theme data (5 files)
│   │   ├── utils/            # Extensions, formatters, validators (3 files)
│   │   └── widgets/          # Reusable widgets (7 files)
│   ├── design_system/        # Comprehensive design system (76 files)
│   │   ├── tokens/           # Raw constants (spacing, radius, elevation, duration, curve, opacity, shadow)
│   │   ├── colors/           # Dual-theme semantic colors (dark + light)
│   │   ├── typography/       # Inter font text styles (22 variants)
│   │   ├── spacing/          # Spacing scale + EdgeInsets helpers
│   │   ├── radius/           # Border radius values + helpers
│   │   ├── elevation/        # Shadow generation from elevation values
│   │   ├── icons/            # Semantic icon registry (80+ icons)
│   │   ├── animations/       # Animation configs (page, dialog, sheet transitions)
│   │   ├── responsive/       # Breakpoints, device detection, responsive helpers
│   │   ├── shadows/          # (empty, tokens in tokens/)
│   │   ├── layouts/          # Shell navigation (PremiumShell, sidebar, drawer, nav) (12 files)
│   │   ├── widgets/          # UI components (buttons×8, inputs×5, surfaces×7, feedback×4, misc×7)
│   │   ├── components/       # Barrel re-export of widgets + layouts
│   │   ├── utils/            # Context extensions, widget extensions
│   │   └── design_system.dart# Master barrel export
│   ├── models/               # Firestore data models (8 files)
│   │   ├── user_model.dart   # UserModel + UserRole enum
│   │   ├── player_model.dart # PlayerModel (linked to parent)
│   │   ├── coach_model.dart  # CoachModel (subscription tiers, ratings)
│   │   ├── academy_model.dart# AcademyModel (reputation, placements)
│   │   ├── venue_model.dart  # VenueModel (geolocation, Google Places)
│   │   ├── chat_model.dart   # ChatModel + ChatMessage + MessageType enum
│   │   ├── contract_model.dart # ContractModel + ContractStatus/Type enums
│   │   └── gamification_model.dart # LevelModel, RankModel, AchievementModel (static data)
│   ├── services/             # Firestore service layer (9 files)
│   │   ├── firebase_service.dart  # Root providers (FirebaseAuth, Firestore, Storage, AuthService)
│   │   ├── auth_service.dart      # Auth CRUD, profile, photo upload, admin tasks, coupons
│   │   ├── academy_service.dart   # Academy CRUD, batches, placements, campaigns, jobs, invitations
│   │   ├── coach_service.dart     # Coach CRUD, sessions, stats, milestones
│   │   ├── player_service.dart    # Player CRUD, metrics, points
│   │   ├── venue_service.dart     # Venue CRUD, search
│   │   ├── chat_service.dart      # Chat CRUD, messaging
│   │   ├── contract_service.dart  # Contract CRUD, signing, fee calculation
│   │   └── providers.dart         # ~30+ StreamProvider/FutureProvider definitions
│   ├── providers/            # Auth-specific providers (1 file)
│   │   └── auth_provider.dart # authStateProvider, userProfileProvider
│   └── features/             # Feature modules (13 subfolders, ~55 files)
│       ├── auth/             # Splash, Login, Signup, Forgot Password (4 screens)
│       ├── home/             # RoleRouter, 5 role shells, 15+ tab screens (22 files)
│       ├── player/           # Player dashboard + 14 widget files
│       ├── coach/            # Coach dashboard + create session (2 files)
│       ├── academy/          # Academy dashboard (1 file)
│       ├── admin/            # Admin dashboard (1 file)
│       ├── venue/            # Venue discovery + detail (2 files)
│       ├── chat/             # Chat list + detail (2 files)
│       ├── contracts/        # Contract list + detail (2 files)
│       ├── community/        # Community feed (1 file)
│       ├── squad_goals/      # Squad goals screen + service + providers (3 files)
│       ├── video_analysis/   # Video analysis screen + service + providers (3 files)
│       └── parent_player/    # EMPTY directory
├── firebase.json             # Firebase project config
├── firestore.rules           # Firestore security rules (67 lines)
├── firestore.indexes.json    # Firestore indexes
├── storage.rules             # Firebase Storage rules (17 lines)
├── .firebaserc               # Firebase project alias
├── firebase_setup.sh         # Firebase setup script
├── pubspec.yaml              # Dependencies + asset declarations
└── analysis_options.yaml     # Linter configuration
```

---

## 4. Application Flow

### App Launch Sequence

```
main()
  └─> WidgetsFlutterBinding.ensureInitialized()
  └─> Firebase.initializeApp()          # Firebase core setup
  └─> SystemChrome orientation/UI config
  └─> runApp(ProviderScope(SportsEcoApp))

SportsEcoApp (ConsumerWidget)
  └─> MaterialApp.router
        ├─> Theme: AppTheme.dark (default) / AppTheme.light
        ├─> Router: buildRouter(ref) via go_router
        └─> Debug banner: disabled
```

### Authentication Flow

```
SplashScreen (/)
  ├─> Checks FirebaseAuth.currentUser
  ├─> If logged in → redirect to /home
  ├─> If not logged in → redirect to /login
  └─> 2-second minimum display with fade animation

LoginScreen (/login)
  ├─> Email + password form
  ├─> Google Sign-In button
  ├─> "Forgot password?" → /forgot-password
  ├─> "Sign up" → /signup
  └─> On success → /home

SignupScreen (/signup)
  ├─> Step 1: Role selection (Player/Coach/Academy/Parent)
  ├─> Step 2: Personal info (name, email, phone)
  ├─> Step 3: Credentials (password, terms)
  └─> On success → /home

GoRouter Auth Guard:
  ├─> If user logged in + on auth route → redirect /home
  └─> If user NOT logged in + on protected route → redirect /login
```

### Post-Auth Navigation (RoleRouter)

```
/home → RoleRouter
  ├─> Reads Firebase auth UID
  ├─> Fetches UserModel from Firestore
  ├─> Checks UserModel.role enum value
  │
  ├─> role == "parent"    → ParentShell    (5 tabs)
  │   ├─> Dashboard (parent_dashboard)
  │   ├─> Coaches (coach_discovery)
  │   ├─> Progress (parent_progress)
  │   ├─> Chat (chat_list)
  │   └─> Profile (profile_page)
  │
  ├─> role == "player"    → PlayerShell    (8 tabs)
  │   ├─> Dashboard (player_dashboard)
  │   ├─> Performance (performance_tab)
  │   ├─> AI Coach (video_analysis)
  │   ├─> Community (community_screen)
  │   ├─> Chat (chat_list)
  │   ├─> Coaches (coach_discovery)
  │   ├─> Squad Goals (squad_goals)
  │   └─> Profile (profile_page)
  │
  ├─> role == "coach"     → CoachShell     (8 tabs)
  │   ├─> Dashboard (coach_dashboard)
  │   ├─> Schedule (schedule_tab)
  │   ├─> Students (students_tab)
  │   ├─> Earnings (earnings_tab)
  │   ├─> Jobs (coach_academy_jobs)
  │   ├─> Community (community_screen)
  │   ├─> Chat (chat_list)
  │   └─> Profile (profile_page)
  │
  ├─> role == "academy"   → AcademyShell   (7 tabs)
  │   ├─> Dashboard (academy_dashboard)
  │   ├─> Batches (batches_tab)
  │   ├─> Coaches (academy_coaches_tab)
  │   ├─> Advertising (advertising_tab)
  │   ├─> Jobs (academy_jobs_tab)
  │   ├─> Chat (chat_list)
  │   └─> Profile (profile_page)
  │
  └─> role == "admin"     → AdminShell     (5 tabs)
      ├─> Dashboard (admin_dashboard)
      ├─> Venues (venue_discovery)
      ├─> Users (users_tab)
      ├─> Coupons (coupons_tab)
      └─> Profile (profile_page)
```

---

## 5. User Roles

### Role: Parent

| Aspect | Details |
|---|---|
| **Identity** | Parent/guardian managing child athlete(s) |
| **Shell Tabs** | Dashboard, Coaches, Progress, Chat, Profile |
| **Key Features** | Multi-player overview, child progress tracking, coach discovery, coach booking, session monitoring |
| **Available Screens** | Parent Dashboard, Coach Discovery, Parent Progress, Chat List/Detail, Profile |
| **Implementation Status** | Dashboard: EXISTS, Progress tab: EXISTS, Coach Discovery: EXISTS, Profile: EXISTS |
| **Missing** | Child linking wizard, multi-account switching, session booking flow |

### Role: Player

| Aspect | Details |
|---|---|
| **Identity** | Young athlete (8-25) tracking training and growth |
| **Shell Tabs** | Dashboard, Performance, AI Coach, Community, Chat, Coaches, Squad Goals, Profile |
| **Key Features** | Performance metrics, video analysis, squad goals, community posting, achievement system, gamification |
| **Available Screens** | Player Dashboard (14 widgets), Performance Tab, Video Analysis, Community, Chat, Coach Discovery, Squad Goals, Profile |
| **Implementation Status** | All 8 tabs: EXIST. Dashboard: EXISTS (rich, 14 widget files) |
| **Missing** | Session booking flow, session detail, session history dedicated screen, onboarding wizard |

### Role: Coach

| Aspect | Details |
|---|---|
| **Identity** | Sports trainer (independent or academy-affiliated) |
| **Shell Tabs** | Dashboard, Schedule, Students, Earnings, Jobs, Community, Chat, Profile |
| **Key Features** | Session management, student roster, earnings tracking, milestone system, subscription tiers, academy job applications |
| **Available Screens** | Coach Dashboard (985 lines, very feature-rich), Schedule Tab, Students Tab, Earnings Tab, Coach Academy Jobs, Create Session, Community, Chat, Profile |
| **Implementation Status** | All 8 tabs: EXIST. Dashboard is the most complex screen in the app |
| **Missing** | Availability calendar, session accept/reject flow, reschedule, session notes/feedback, attendance tracking, profile setup wizard |

### Role: Academy

| Aspect | Details |
|---|---|
| **Identity** | Sports academy organization |
| **Shell Tabs** | Dashboard, Batches, Coaches, Advertising, Jobs, Chat, Profile |
| **Key Features** | Batch management, coach recruitment/placement, advertising campaigns, job posting, reputation system |
| **Available Screens** | Academy Dashboard (687 lines), Batches Tab, Academy Coaches Tab, Advertising Tab, Academy Jobs Tab, Chat, Profile |
| **Implementation Status** | All 7 tabs: EXIST |
| **Missing** | Student enrollment flow, batch detail view, coach invitation acceptance, profile setup wizard |

### Role: Admin

| Aspect | Details |
|---|---|
| **Identity** | Platform administrator |
| **Shell Tabs** | Dashboard, Venues, Users, Coupons, Profile |
| **Key Features** | Platform metrics, user management, venue CRUD, coupon management, task management, revenue tracking |
| **Available Screens** | Admin Dashboard (603 lines), Venue Discovery, Users Tab, Coupons Tab, Profile |
| **Implementation Status** | All 5 tabs: EXIST |
| **Missing** | Venue partner dashboard (separate role), analytics deep-dives |

---

## 6. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                         │
│                                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────────┐ │
│  │ auth/        │  │ home/        │  │ features/                 │ │
│  │ (4 screens)  │  │ (22 files)   │  │ player/  coach/  academy/ │ │
│  │              │  │ RoleRouter   │  │ admin/   venue/   chat/   │ │
│  │ Splash       │  │ 5 Shells     │  │ contracts/ community/    │ │
│  │ Login        │  │ 15+ Tabs     │  │ squad_goals/ video_      │ │
│  │ Signup       │  │              │  │ analysis/                │ │
│  │ Forgot Pwd   │  │              │  │                           │ │
│  └──────┬───────┘  └──────┬───────┘  └─────────────┬─────────────┘ │
│         │                 │                        │               │
│         └─────────────────┼────────────────────────┘               │
│                           │                                        │
│  ┌────────────────────────┴──────────────────────────────────────┐ │
│  │                    WIDGETS / COMPONENTS                        │ │
│  │  core/widgets/         design_system/widgets/                 │ │
│  │  (7 widgets)           (31 components: buttons, inputs,       │ │
│  │                         surfaces, feedback, misc)             │ │
│  │  design_system/layouts/ (12 navigation/shell layouts)         │ │
│  └────────────────────────┬──────────────────────────────────────┘ │
│                           │                                        │
├───────────────────────────┼────────────────────────────────────────┤
│                     STATE LAYER                                    │
│                           │                                        │
│  ┌────────────────────────┴──────────────────────────────────────┐ │
│  │                    RIVERPOD PROVIDERS                          │ │
│  │                                                               │ │
│  │  providers/auth_provider.dart                                  │ │
│  │    ├─ authStateProvider (StreamProvider<User?>)                │ │
│  │    └─ userProfileProvider (FutureProvider<UserModel?>)         │ │
│  │                                                               │ │
│  │  services/providers.dart (~30 providers)                       │ │
│  │    ├─ Service Providers (6): venue, chat, contract, coach,     │ │
│  │    │                        academy, player                   │ │
│  │    └─ Data Providers (~24): StreamProvider.family.autoDispose  │ │
│  │                             for all Firestore collections      │ │
│  │                                                               │ │
│  │  features/squad_goals/providers/  (3 local providers)          │ │
│  │  features/video_analysis/providers/ (3 local providers)        │ │
│  │                                                               │ │
│  │  core/theme/theme_provider.dart (theme persistence)           │ │
│  └────────────────────────┬──────────────────────────────────────┘ │
│                           │                                        │
├───────────────────────────┼────────────────────────────────────────┤
│                     SERVICE LAYER                                  │
│                           │                                        │
│  ┌────────────────────────┴──────────────────────────────────────┐ │
│  │                    FIREBASE SERVICES                           │ │
│  │                                                               │ │
│  │  firebase_service.dart  (root providers: FirebaseAuth,        │ │
│  │                          FirebaseFirestore, FirebaseStorage)    │ │
│  │  auth_service.dart      (auth, profile, coupons, admin tasks) │ │
│  │  coach_service.dart     (coach CRUD, sessions, stats)         │ │
│  │  academy_service.dart   (batches, placements, jobs, invites)  │ │
│  │  player_service.dart    (player CRUD, metrics, points)        │ │
│  │  venue_service.dart     (venue CRUD, search)                  │ │
│  │  chat_service.dart      (chat CRUD, messaging)                │ │
│  │  contract_service.dart  (contract CRUD, signing, fees)        │ │
│  └────────────────────────┬──────────────────────────────────────┘ │
│                           │                                        │
├───────────────────────────┼────────────────────────────────────────┤
│                     DATA LAYER                                     │
│                           │                                        │
│  ┌────────────────────────┴──────────────────────────────────────┐ │
│  │                    MODELS                                      │ │
│  │  user_model.dart       (UserRole enum, UserModel)             │ │
│  │  player_model.dart     (PlayerModel)                          │ │
│  │  coach_model.dart      (CoachModel)                           │ │
│  │  academy_model.dart    (AcademyModel)                         │ │
│  │  venue_model.dart      (VenueModel)                           │ │
│  │  chat_model.dart       (ChatModel, ChatMessage, MessageType)  │ │
│  │  contract_model.dart   (ContractModel, ContractStatus/Type)   │ │
│  │  gamification_model.dart (LevelModel, RankModel, Achievement) │ │
│  └────────────────────────┬──────────────────────────────────────┘ │
│                           │                                        │
├───────────────────────────┼────────────────────────────────────────┤
│                     EXTERNAL SERVICES                              │
│                           │                                        │
│  ┌────────────────────────┴──────────────────────────────────────┐ │
│  │  Firebase Auth         (authentication)                        │ │
│  │  Cloud Firestore       (primary database, 18+ collections)    │ │
│  │  Firebase Storage      (profile photos, videos)               │ │
│  │  Firebase Messaging    (declared, limited integration)        │ │
│  │  Google Maps Flutter   (declared, limited integration)        │ │
│  │  Google Fonts API      (Poppins + Inter)                      │ │
│  │  SharedPreferences     (theme persistence only)               │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│                     SUPPORTING LAYERS                              │
│                                                                    │
│  core/constants/    app_constants.dart (app identity, sports,     │
│                                    fees, limits, subscription tiers)│
│  core/utils/        extensions, formatters, validators            │
│  core/theme/        app_colors, app_text_styles, app_theme,      │
│                     app_dimensions, theme_provider                │
│  core/routing/      app_router.dart (GoRouter, 15+ routes)       │
│  design_system/     76-file comprehensive design system           │
│                     tokens → colors → typography → widgets →      │
│                     layouts → responsive                           │
└────────────────────────────────────────────────────────────────────┘
```

### Firestore Collections Map (18+)

```
users              ← AuthService (user profiles, roles)
coaches            ← CoachService, AuthService, AcademyService
academies          ← AcademyService, AuthService
players            ← PlayerService, AuthService
venues             ← VenueService
chats/             ← ChatService (chat documents)
  {id}/messages/   ← ChatService (subcollection)
sessions           ← CoachService
contracts          ← ContractService
batches            ← AcademyService
academyPlacements  ← AcademyService
campaigns          ← AcademyService
coachInvitations   ← AcademyService
coachJobs          ← AcademyService
jobApplications    ← AcademyService
playerMetrics      ← PlayerService
coachMilestones    ← CoachService
coupons            ← AuthService
adminTasks         ← AuthService
playerAchievements ← providers.dart (inline)
posts              ← providers.dart (inline)
squadGoals         ← SquadGoalsService
videoAnalysis      ← VideoAnalysisService
notifications      ← (firestore rules defined, service not yet created)
```

---

## 7. Current Completion Percentage

### Overall Estimate: ~70% Complete (UI/Structure), ~50% Complete (End-to-End Functionality)

| Category | Status | Percentage |
|---|---|---|
| **Completed** | Auth flow (login/signup/forgot password/google), all 5 role shells, role routing, all dashboards (5), design system (76 files), core infrastructure, data models (8), services (7), provider layer (~30+ providers), venue discovery + detail, chat list + detail, contract list + detail, community feed UI, squad goals, video analysis, player dashboard (14 widgets), coach dashboard (985 lines), academy dashboard, admin dashboard, profile page, Firestore rules, Firebase config | **70%** |
| **Partially Completed** | Coach discovery (UI exists, booking flow missing), session management (create exists, booking/accept/reject/reschedule missing), venue map integration (package declared, UI not built), community feed (posting works, like/comment/share are "coming soon"), Google Sign-In (implemented in service, Google provider not fully declared in providers.dart) | **15%** |
| **Missing** | Phone OTP auth, onboarding wizards (role-specific), session booking flow (player-side), session accept/reject (coach-side), availability calendar, session detail screen, session history (dedicated), attendance tracking, coach reviews UI, venue booking calendar, venue partner dashboard, student enrollment flow, batch detail view, notifications system, payment integration (escrow model designed but no payment gateway), account deletion, multi-account switching for parents, error boundary/offline handling, comprehensive testing | **15%** |

### Feature-Level Breakdown

| Feature Module | Files | Completion | Notes |
|---|---|---|---|
| `auth/` | 4 screens | ✅ 95% | Missing: phone OTP, onboarding wizards |
| `home/` | 22 files | ✅ 90% | All shells + tabs implemented |
| `player/` | 14 files | ✅ 85% | Rich dashboard, missing session booking |
| `coach/` | 2 files | ⚠️ 70% | Dashboard very rich, missing calendar/accept/reject |
| `academy/` | 1 file | ⚠️ 65% | Dashboard exists, missing enrollment/detail screens |
| `admin/` | 1 file | ⚠️ 65% | Dashboard exists, missing deep analytics |
| `venue/` | 2 files | ⚠️ 60% | Discovery/detail exist, missing map/booking |
| `chat/` | 2 files | ✅ 80% | List + detail exist |
| `contracts/` | 2 files | ✅ 80% | List + detail exist, signing works |
| `community/` | 1 file | ⚠️ 50% | Posting works, interactions are "coming soon" |
| `squad_goals/` | 3 files | ✅ 75% | Has own service + providers |
| `video_analysis/` | 3 files | ✅ 75% | Has own service + providers |
| `parent_player/` | 0 files | ❌ 0% | Empty directory |

---

## 8. Critical Findings

### Bad Architecture Decisions

1. **Monolithic Dashboard Files**: `coach_dashboard.dart` (985 lines), `academy_dashboard.dart` (687 lines), `admin_dashboard.dart` (603 lines) are overly large single files. These should be decomposed into smaller, focused widgets like the player dashboard (14 separate widget files).

2. **Dual Design Systems**: The project has TWO competing design systems — `core/theme/` (AppColors, AppTextStyles, AppTheme) and `design_system/` (76 files with its own colors, typography, tokens, widgets). Many feature screens import from `core/theme` while the design system exists. This creates confusion and visual inconsistency. The dashboard screens are flagged as "REDESIGN" in the screen inventory because of this.

3. **Duplicated `_parseTimestamp()` Helper**: The exact same `_parseTimestamp()` function is copy-pasted into every model file (academy_model.dart, chat_model.dart, coach_model.dart, player_model.dart, user_model.dart). This should be extracted to a shared utility.

4. **Flat Provider Architecture**: Almost all ~30+ providers live in a single `services/providers.dart` file (243 lines). While only 2 features (squad_goals, video_analysis) have local providers, the rest all pull from the central registry. This doesn't scale well and creates tight coupling.

5. **Client-Side Search**: Both `CoachService.searchCoaches()` and `VenueService.searchVenues()` fetch ALL documents from Firestore then filter in Dart. This works at small scale but will not scale for production with thousands of records. Server-side Firestore queries with `where` clauses or Algolia/Elasticsearch integration is needed.

6. **No Error Handling Layer**: Services return streams/futures directly without a unified error handling strategy. There's no `Either<L, R>` pattern, no Result wrapper, and the UI relies on stream `.when()` with basic loading/error states.

### Technical Debt

1. **No Tests**: The `test/` directory exists but contains no meaningful test files. Zero unit tests, widget tests, or integration tests.

2. **Firebase Project Mismatch**: The `firebase_options.dart` was generated for project `auth-for-docs` (a generic Firebase project), not a dedicated `sportseco` or `sports-app` project. The iOS bundle ID is `com.example.coachBooking` — a leftover from a different project. This is a significant production blocker.

3. **No Payment Integration**: The contract system has a fully designed fee model (10% platform fee, 10% opportunity fee, 10% discount, escrow), but there is zero payment gateway integration (no Razorpay, Stripe, or Paytm). The escrow model is purely a data field.

4. **Push Notifications Unimplemented**: `firebase_messaging: ^16.0.4` and `flutter_local_notifications: ^22.0.0` are declared as dependencies but there's no notification service, no FCM token management, and no notification handlers in the codebase.

5. **Google Maps Declared but Unused**: `google_maps_flutter: ^2.12.0`, `geolocator: ^14.0.2`, and `geocoding: ^4.0.0` are in pubspec.yaml but there's no map screen, no location-based venue search, and no geolocation features implemented.

6. **`parent_player/` Empty Directory**: This directory exists but has zero files. Its functionality was apparently absorbed into `home/` tab screens, but the empty directory creates confusion.

7. **Firestore Security Rules Too Permissive**: The catch-all rule at the bottom (`match /{document=**} { allow read, write: if request.auth != null; }`) grants authenticated users full read/write access to ANY collection, bypassing all the specific rules above it. This is a security concern.

8. **Lottie Dependency Version Mismatch**: `lottie: ^3.3.1` is a very old version (current is 3.x+). The actual API for Lottie has changed significantly across major versions.

### Risk Areas

1. **Scaling**: Client-side search, monolithic files, and no caching layer will cause performance issues as data grows.

2. **Security**: The Firestore catch-all rule and the absence of admin role verification in Firestore rules (only checked client-side in the router) means any authenticated user could potentially access admin data.

3. **No Offline Support**: The app has no offline handling strategy. All data comes from Firestore streams with no local caching beyond SharedPreferences for theme mode.

4. **Production Readiness**: The Firebase project is a dev/test project (`auth-for-docs`), bundle IDs use `com.example.*`, and there's no CI/CD, no crash reporting (Firebase Crashlytics), and no analytics (Firebase Analytics) integrated.

5. **Design System Fragmentation**: The existence of two parallel design systems means any new screen developer must choose which to use, leading to visual inconsistency and maintenance burden.

---

*End of PROJECT_ANALYSIS.md*
