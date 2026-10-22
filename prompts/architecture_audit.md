# Sports_App — Architecture Audit Report

> **Date:** 2026-07-08
> **Project:** SportsEco (Flutter)
> **State Management:** Riverpod v3.3.1
> **Backend:** Firebase (Auth, Firestore, Storage)
> **Routing:** GoRouter v17.3.0

---

## 1. Firestore Collections

| Collection | Used In | Sources Data | Writes Data | Status |
|---|---|---|---|---|
| `users` | Auth, Profile, Shells | `AuthService` | `AuthService.signUp()` | ✅ Active |
| `players` | Player dashboard, stats | `PlayerService` | `PlayerService` | ✅ Active |
| `coaches` | Coach dashboard, discovery | `CoachService` | `CoachService` | ✅ Active |
| `academies` | Academy dashboard | `AcademyService` | `AcademyService` | ✅ Active |
| `venues` | Venue discovery | `VenueService` | `VenueService` | ✅ Active |
| `chats` | Chat list | `ChatService` | `ChatService` | ✅ Active |
| `messages` | Chat detail | `ChatService` | `ChatService` | ✅ Active |
| `contracts` | Contract list/detail | `ContractService` | `ContractService` | ✅ Active |
| `sessions` | Coach/Player schedule | `CoachService` | `CoachService` | ✅ Active |
| `batches` | Academy batches | `AcademyService` | `AcademyService` | ✅ Active |
| `coupons` | Admin coupons | `AuthService` | `AuthService` | ✅ Active |
| `coachMilestones` | Coach dashboard | `CoachService` | `CoachService` | ✅ Active |
| `academyPlacements` | Academy placements | `AcademyService` | `AcademyService` | ✅ Active |
| `playerMetrics` | Performance charts | `PlayerService` | `PlayerService` | ✅ Active |
| `videoAnalysis` | Video analysis | `VideoAnalysisService` | `VideoAnalysisService` | ✅ Active |
| `squadGoals` | Squad goals | `SquadGoalsService` | `SquadGoalsService` | ✅ Active |
| `playerAchievements` | Achievements | `PlayerService` | `PlayerService` | ✅ Active |
| `notifications` | Notifications (planned) | — | — | ❌ Empty / Unused |
| `campaigns` | Academy advertising | `AcademyService` | `AcademyService` | ✅ Active |
| `coachInvitations` | Academy coaches tab | `AcademyService` | `AcademyService` | ✅ Active |
| `coachJobs` | Academy jobs | `AcademyService` | `AcademyService` | ✅ Active |
| `jobApplications` | Job applications | `AcademyService` | `AcademyService` | ✅ Active |
| `adminTasks` | Admin dashboard | `AuthService` | `AuthService` | ✅ Active |

### Missing Collections (needed but not created)

| Collection | Needed For | Priority |
|---|---|---|
| `posts` / `socialFeed` | Community screen (currently mock data) | Medium |
| `dailyMissions` / `dailyChallenges` | Daily missions section (currently hardcoded) | Low (Phase 1.2) |
| `playerStreaks` | Streak tracking in hero section | Low (Phase 1.3) |
| `aiInsights` | AI insight section | Low (Phase 1.x) |
| `subscriptions` / `payments` | Subscription management (Manage Plan) | Medium |
| `reports` | Parent/Coach reports | Low |
| `notifications` (populate) | Notification bell/feed | Medium |

---

## 2. Existing Features by Module (with % Complete)

### Authentication — 95%
- [x] Email/Password sign-in
- [x] Google Sign-In
- [x] 3-step role-based signup (role → personal → credentials)
- [x] Forgot password
- [x] Profile update (name, phone, photo, city, bio)
- [x] Password update
- [x] Auth state persistence
- [x] Role-based routing redirect
- [ ] Email verification enforcement (missing)
- [ ] Phone number verification (missing)

### Player Home — 80%
- [x] Hero section (greeting, XP, level, rank, streak, countdown)
- [x] Today's Focus (rotating daily card)
- [x] Daily Missions (5 missions with check-off)
- [x] Player Progression (XP, ranks, mini chart)
- [x] Upcoming Session (next session with countdown)
- [x] Quick Actions (grid of action cards)
- [x] Performance Section (line chart)
- [x] Community Preview (trending challenge + users)
- [x] Achievements (horizontal scrollable badges)
- [x] Insights (consistency, weekly activity, AI tips placeholder)
- [x] Daily Motivation (rotating quote/tip)
- [x] Responsive layout (phone/tablet/desktop)
- [x] Shimmer loading states
- [x] Empty states
- [ ] Real Firestore data for daily missions (hardcoded)
- [ ] Real Firestore data for community preview (mock)
- [ ] Real streak data from Firestore
- [ ] Real AI insights (placeholder only)

### Coach — 85%
- [x] Dashboard with real stats (sessions, earnings, students)
- [x] Dynamic milestones (add/complete/delete)
- [x] Schedule tab with player names
- [x] Students tab
- [x] Earnings tab
- [x] Performance tab with metric logging + charts
- [x] Chat integration in navigation
- [x] Video tips (video analysis)
- [x] Academy jobs browsing + applying
- [x] Coach discovery
- [x] "Join" buttons with session action sheet
- [x] Manage Plan with subscription tiers
- [ ] Profile page (uses shared ProfilePage — functional)
- [ ] Real-time notifications

### Academy — 80%
- [x] Dashboard with active coaches count
- [x] Campaign creation (advertising)
- [x] Batch listing from Firestore
- [x] Coach placements
- [x] Verification badge
- [x] Coach invite system (discover + invite + track status)
- [x] Job postings (coachJobs)
- [x] Coach management (my coaches tab)
- [ ] Full coach profile viewing
- [ ] Real-time campaign analytics

### Parent — 50%
- [x] Parent dashboard
- [x] Child progress viewing
- [x] Avg XP fix
- [ ] View Reports button fix (was null)
- [ ] Communication with coaches
- [ ] Payment/subscription management
- [ ] Multiple children management

### Admin — 40%
- [x] Admin dashboard
- [x] User list
- [x] Coupon management (create, list, toggle)
- [ ] Analytics/reports
- [ ] Moderation tools
- [ ] System settings

### Community — 20%
- [x] Community screen UI
- [ ] Real Firestore data (currently mock in-memory)
- [ ] Post creation
- [ ] Likes/comments
- [ ] Feed from Firestore

### Chat — 70%
- [x] Chat list
- [x] Chat detail with messages
- [x] Coach → Player messaging via sessions
- [ ] Real-time presence
- [ ] Read receipts
- [ ] Group chats

### Venue — 60%
- [x] Venue discovery with search
- [x] Venue detail page
- [ ] Booking system
- [ ] Reviews/ratings

### Contracts — 60%
- [x] Contract list
- [x] Contract detail
- [x] Contract signing
- [ ] PDF generation
- [ ] E-signature integration

### Video Analysis — 60%
- [x] Video upload to Firebase Storage
- [x] Analysis results display
- [ ] Real AI analysis backend (placeholder UI)
- [ ] Coach review of analysis

### Squad Goals — 60%
- [x] Full CRUD service
- [x] Squad goals UI
- [x] Firestore integration
- [ ] Goal completion tracking
- [ ] Team progress visualization

---

## 3. Providers (Riverpod)

All defined in `lib/services/providers.dart` (234 lines, 40+ providers):

### Service Providers (singletons)
| Provider | Type | Description |
|---|---|---|
| `authServiceProvider` | Provider | AuthService instance |
| `playerServiceProvider` | Provider | PlayerService instance |
| `coachServiceProvider` | Provider | CoachService instance |
| `academyServiceProvider` | Provider | AcademyService instance |
| `chatServiceProvider` | Provider | ChatService instance |
| `contractServiceProvider` | Provider | ContractService instance |
| `venueServiceProvider` | Provider | VenueService instance |
| `videoAnalysisServiceProvider` | Provider | VideoAnalysisService instance |
| `squadGoalsServiceProvider` | Provider | SquadGoalsService instance |

### Auth Providers
| Provider | Type | Description |
|---|---|---|
| `authStateProvider` | Provider | Current Firebase User (nullable) |
| `userProfileProvider` | FutureProvider | UserModel from Firestore |
| `authLoadingProvider` | StateProvider | Loading state bool |

### Stream Providers
| Provider | Type | Source |
|---|---|---|
| `playerStreamProvider` | StreamProvider | `players/{uid}` |
| `coachStreamProvider` | StreamProvider | `coaches/{uid}` |
| `academyStreamProvider` | StreamProvider | `academies/{uid}` |
| `chatsStreamProvider` | StreamProvider | `chats` |
| `messagesStreamProvider` | StreamProvider.family | `messages/{chatId}` |
| `contractsStreamProvider` | StreamProvider | `contracts` |
| `venuesStreamProvider` | StreamProvider | `venues` |
| `coachMilestonesStreamProvider` | StreamProvider.family | `coachMilestones/{coachId}` |
| `playerAchievementsStreamProvider` | StreamProvider.family | `playerAchievements/{playerId}` |
| `squadGoalsStreamProvider` | StreamProvider | `squadGoals` |

### Future Providers
| Provider | Type | Source |
|---|---|---|
| `playerFutureProvider` | FutureProvider.family | `players/{id}` |
| `coachFutureProvider` | FutureProvider.family | `coaches/{id}` |
| `allCoachesFutureProvider` | FutureProvider | `coaches` |
| `batchesFutureProvider` | FutureProvider.family | `batches/{academyId}` |
| `academyPlacementsFutureProvider` | FutureProvider.family | `academyPlacements/{academyId}` |
| `academyCampaignsProvider` | FutureProvider.family | `campaigns/{academyId}` |
| `coachInvitationsProvider` | FutureProvider.family | `coachInvitations/{academyId}` |
| `academyJobsProvider` | FutureProvider.family | `coachJobs/{academyId}` |
| `allAcademyJobsProvider` | FutureProvider | `coachJobs` |
| `activeCoachesCountProvider` | FutureProvider.family | `coaches` count |
| `couponsProvider` | FutureProvider | `coupons` |
| `adminTasksProvider` | FutureProvider.family | `adminTasks` |

### Issues with Providers
- **No dedicated player dashboard providers** — dashboard sections read directly from `playerStreamProvider` + `playerFutureProvider` + `playerAchievementsStreamProvider`
- **No `dailyMissionsProvider`** — missions are hardcoded in the widget
- **No `todaysFocusProvider`** — focus is hardcoded
- **No `communityPostsProvider`** — community uses mock data
- **No `insightsProvider`** — AI insight is placeholder text
- **No `dailyMotivationProvider`** — motivation is hardcoded rotation
- `playerMetrics` has no dedicated stream provider (used inline in performance section)

---

## 4. Firebase Services

| Service | File | Lines | Responsibility |
|---|---|---|---|
| `AuthService` | `auth_service.dart` | 220 | Auth + coupon + admin task CRUD |
| `PlayerService` | `player_service.dart` | 69 | Player CRUD + metrics + points |
| `CoachService` | `coach_service.dart` | 210 | Coach CRUD + sessions + stats + milestones |
| `AcademyService` | `academy_service.dart` | 230 | Academy CRUD + batches + placements + campaigns + jobs + invitations |
| `ChatService` | `chat_service.dart` | 81 | Chat CRUD + messages |
| `ContractService` | `contract_service.dart` | 108 | Contract CRUD + signing |
| `VenueService` | `venue_service.dart` | 52 | Venue CRUD + search |
| `VideoAnalysisService` | `video_analysis_service.dart` | — | Video upload + analysis |
| `SquadGoalsService` | `squad_goals_service.dart` | — | Squad goals CRUD |

### Issues
- `AuthService` is overloaded — contains coupon management and admin task methods that should be in dedicated services
- No dedicated `NotificationsService`
- No `AnalyticsService`
- No `SocialFeedService` / `PostService`
- All services are client-only — no Cloud Functions for validation, notifications, or complex aggregations
- `UserService` doesn't exist — user CRUD is embedded in `AuthService`

---

## 5. Navigation Flow

```
SplashScreen
  └── LoginScreen
       └── SignupScreen (3-step: role → personal → credentials)
       └── ForgotPasswordScreen
       └── RoleRouter (after auth)
            ├── ParentShell → ParentDashboard, ParentProgress, Profile
            ├── PlayerShell → PlayerDashboard, Community, Chat, SquadGoals, Profile
            ├── CoachShell → CoachDashboard, Schedule, Students, Earnings, Performance, Chat, VideoAnalysis, AcademyJobs, CoachDiscovery, Profile
            ├── AcademyShell → AcademyDashboard, Batches, Coaches, Advertising, Jobs, Venues, Profile
            └── AdminShell → AdminDashboard, Users, Coupons, Tasks, Profile
```

### Issues
- No deep linking support
- No onboarding flow for new users
- No email verification interstitial
- No role-switching support (a user cannot be both parent and coach)
- No 404/page-not-found route

---

## 6. Current Problems

### Dead Code (Duplicate Widgets from Incomplete Refactoring)

| Old File | New File | Action |
|---|---|---|
| `dashboard_sessions_section.dart` | `upcoming_session_section.dart` | Delete old |
| `dashboard_kpi_section.dart` | (none — replaced by hero + progression) | Delete |
| `dashboard_performance_section.dart` | `performance_section.dart` | Delete old |
| `dashboard_quick_actions.dart` | `quick_actions_section.dart` | Delete old |
| `dashboard_header.dart` | (merged into hero_section) | Delete |
| `dashboard_coach_carousel.dart` | (not in new dashboard) | Delete |
| `dashboard_activity_timeline.dart` | (not in new dashboard) | Delete |
| `dashboard_error_state.dart` | (merged into empty_state) | Delete |
| `dashboard_community_preview.dart` | `community_section.dart` | Delete old |
| `dashboard_achievement_section.dart` | `achievements_section.dart` | Delete old |

### Unused / Dead Imports
- Some sections in `dashboard_page.dart` may reference old widget paths
- `dashboard_loading.dart` defined but usage should be verified

### Broken Flows
- **Parent "View Reports" button** — was null (fixed in earlier session)
- **Parent "Avg XP"** — was using wins instead of points (fixed)
- **Community screen** — all data is mock (no Firestore collection)
- **Daily missions** — hardcoded list, cannot be persisted or varied per player
- **AI Insights** — "Your AI insight will appear here" placeholder only
- **Streak counting** — no persistence (resets on app restart)
- **Email verification** — signup doesn't enforce email verification before allowing access
- **No loading/error states** — some dashboard sections may lack proper Riverpod `AsyncValue` handling

### Fake / Hardcoded Data
- Daily missions (5 hardcoded items)
- Today's Focus (rotating hardcoded cards)
- Community preview (mock users + challenges)
- Daily motivation (hardcoded rotation of quotes/tips)
- AI insights (static placeholder text)
- Streak count (not persisted)

### TODOs in Codebase
(Needs scan — likely scattered across dashboard widgets as placeholder comments)

### Architecture Issues
- `AuthService` handles too many domains (coupons, admin tasks)
- No repository layer — services talk directly to Firebase
- No offline-first strategy (Firestore's built-in persistence may be disabled or not configured)
- No error handling abstraction — try/catch scattered across services
- No pagination for list views (chats, contracts, venues, etc.)
- No caching layer for future providers (every rebuild re-fetches)

---

## 7. Missing Backend

### Cloud Functions (Needed)
| Function | Priority | Reason |
|---|---|---|
| `onUserCreate` → create user profile document | High | Currently done client-side |
| `sendNotification` | Medium | Push notifications |
| `processVideoAnalysis` | Medium | Server-side AI processing |
| `calculatePlayerStats` | Low | Aggregation for leaderboards |
| `emailVerification` | Low | Server-side verification checks |

### Security Rules
- `firestore.rules` exists — needs audit for proper validation
- No rate limiting
- No write validation for most collections

---

## 8. Missing UI

| Feature | Module | Priority |
|---|---|---|
| Onboarding flow | Auth | Medium |
| Email verification screen | Auth | Medium |
| Notifications bell + feed | Global | Medium |
| Search (global) | Global | Low |
| Settings screen (separate from profile) | Global | Low |
| Help/FAQ screen | Global | Low |
| Report a problem | Global | Low |
| Player history / session log | Player | Low |
| Coach rating / reviews | Coach | Low |
| Payment method management | Coach/Parent | Medium |
| Subscription management (real) | Coach/Parent | Medium |
| Group chat creation | Chat | Low |
| Share profile | Profile | Low |
| Dark mode toggle (works) | Profile | ✅ Done |

---

## 9. Feature Dependency Graph

```
Authentication (required by ALL)
    └── Player Home (requires playerStreamProvider, playerAchievementsStreamProvider)
    │       ├── Hero (requires: userProfile, playerProfile)
    │       ├── Today's Focus (requires: nothing — hardcoded)
    │       ├── Daily Missions (requires: nothing — hardcoded)
    │       ├── Progression (requires: playerMetrics)
    │       ├── Upcoming Session (requires: sessions collection)
    │       ├── Quick Actions (requires: nothing — static navigation)
    │       ├── Performance (requires: playerMetrics)
    │       ├── Community Preview (requires: posts collection — MOCK)
    │       ├── Achievements (requires: playerAchievements collection)
    │       ├── Insights (requires: playerMetrics — AI placeholder)
    │       └── Daily Motivation (requires: nothing — hardcoded)
    ├── Coach Dashboard (requires: coachStreamProvider, sessions, milestones)
    ├── Academy Dashboard (requires: academyStreamProvider, batches, campaigns)
    ├── Parent Dashboard (requires: players collection for children)
    ├── Community (requires: posts collection — MOCK)
    ├── Chat (requires: chats + messages collections)
    ├── Venue (requires: venues collection)
    ├── Contracts (requires: contracts collection)
    ├── Video Analysis (requires: videoAnalysis + Firebase Storage)
    └── Squad Goals (requires: squadGoals collection)
```

---

## 10. Module Scores (out of 10)

| Module | Score | Notes |
|---|---|---|
| **Authentication** | 8/10 | Missing email verification, phone auth |
| **UI/UX Design** | 7/10 | Beautiful design system but duplicate widgets, incomplete states |
| **Architecture** | 6/10 | No repository layer, overloaded AuthService, no offline strategy |
| **Scalability** | 5/10 | No pagination, no Cloud Functions, client-only aggregations |
| **Code Quality** | 6/10 | Dead code, duplicate widgets, mixed responsibilities |
| **Backend (Firebase)** | 5/10 | No Cloud Functions, no notification service, mock data for key features |
| **UX (Loading/Error/Empty)** | 6/10 | Shimmer loading exists, but some sections lack error/empty states |
| **State Management** | 7/10 | Riverpod correctly used, but missing providers for hardcoded data |
| **Responsive Design** | 8/10 | Phone/tablet/desktop via `dashboard_page.dart` + responsive helpers |
| **Firestore Structure** | 6/10 | Decent schema but missing collections (posts, missions, streaks) |
| **Maintainability** | 5/10 | Dead code, duplicated files, AuthService bloat, no repository pattern |

### Overall Completion: ~65%

This accounts for the fact that the 5 shell UIs exist with navigation, authentication is solid, the player dashboard has all 11 visual sections, and coach/academy dashboards are feature-rich — but significant portions rely on mock/hardcoded data, there's substantial dead code, and backend infrastructure (Cloud Functions, push notifications, email verification, real social feed) is missing.

---

## 11. Phase 1 Priority: Player Home — Implementation Hooks

Per the strict roadmap, Phase 1 focuses **only** on the Player Home Experience. The following architecture should be followed:

### Data Flow
```
dashboard_page.dart
  └── Reads: authStateProvider → userProfileProvider → playerStreamProvider
  └── Passes: AsyncValue<UserModel?>, AsyncValue<PlayerModel?> to each section widget
  └── Each section handles loading/error/data internally
```

### Reuse Existing (DO NOT create new providers/services for these)
- `playerStreamProvider` → player profile + stats
- `userProfileProvider` → user display name, email, photo
- `playerAchievementsStreamProvider` → achievement badges
- `sessions` collection → upcoming session data
- `playerMetrics` → performance chart data

### Placeholder Sections (hardcoded data OK for now)
- `todays_focus_section.dart` — rotating hardcoded cards
- `daily_missions_section.dart` — 5 hardcoded missions with local check-off
- `community_section.dart` — mock users (waiting for posts collection)
- `insights_section.dart` — AI placeholder text
- `bottom_section.dart` — hardcoded motivation rotation

### Graceful Empty States
- Every section must handle: `AsyncValue.loading` → shimmer, `AsyncValue.error` → retry/empty, `AsyncValue.data` with null → empty state widget

### DO NOT
- Create XP backend (Phase 2)
- Implement rankings (Phase 3)
- Build social feed (Phase 4)
- Build group chat (Phase 4)
- Add signup validation beyond what exists (already done)
- Duplicate any existing provider, service, or model
- Create fake/dummy providers

---

## Appendix: File Inventory by Directory

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp.router
├── firebase_options.dart              # Generated
├── core/
│   ├── constants/app_constants.dart
│   ├── routing/app_router.dart        # GoRouter
│   ├── theme/ (app_colors, app_theme, app_text_styles, app_dimensions, theme_provider)
│   ├── utils/ (extensions, formatters, validators)
│   └── widgets/ (profile_page, gradient_button, stats_card, section_header, app_scaffold, glass_morphism, loading_shimmer)
├── design_system/
│   ├── tokens/ (colors, typography, spacing, radius, elevation, icons, animations)
│   ├── responsive/responsive_helpers.dart
│   ├── layouts/ (premium_shell, premium_nav_item)
│   └── widgets/ (buttons, cards, inputs, avatars, etc.)
├── models/
│   ├── user_model.dart
│   ├── player_model.dart
│   ├── coach_model.dart
│   ├── academy_model.dart
│   ├── chat_model.dart
│   ├── contract_model.dart
│   ├── venue_model.dart
│   └── gamification_model.dart
├── services/
│   ├── firebase_service.dart          # Firebase init + provider instances
│   ├── providers.dart                 # All service + stream/future providers
│   ├── auth_service.dart
│   ├── player_service.dart
│   ├── coach_service.dart
│   ├── academy_service.dart
│   ├── chat_service.dart
│   ├── contract_service.dart
│   ├── venue_service.dart
│   ├── video_analysis_service.dart
│   └── squad_goals_service.dart
├── providers/
│   └── auth_provider.dart
├── features/
│   ├── auth/presentation/ (splash, login, signup, forgot_password)
│   ├── home/presentation/ (role_router, shells, per-role dashboards/tabs)
│   ├── player/presentation/dashboard/ (dashboard_page + 11 section widgets)
│   ├── community/presentation/community_screen.dart
│   ├── chat/presentation/ (chat_list, chat_detail)
│   ├── venue/presentation/ (venue_discovery, venue_detail)
│   ├── contracts/presentation/ (contract_list, contract_detail)
│   ├── video_analysis/ (screen + service + providers)
│   └── squad_goals/ (screen + service + providers)
└── firebase/ (firestore.indexes.json, firestore.rules, firebase.json)
```
