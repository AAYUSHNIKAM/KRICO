# 09 — Backlog

---

## Must Have (Blocking MVP Launch)

| ID | Priority | Module | Item | Why |
|----|----------|--------|------|-----|
| M1 | Critical | Firebase | Replace `auth-for-docs` demo project with real Firebase project | Without this, nothing works in production |
| M2 | Critical | Auth | Implement email verification flow | Without it, accounts are unverified and insecure |
| M3 | Critical | Auth | Fix `authLoadingProvider` (currently hardcoded to `false`) | Auth state is unreliable without loading indicators |
| M4 | Critical | Auth | Fix signup: `PlayerModel.parentId` should NOT equal `uid` | Player should not be their own parent |
| M5 | Critical | Community | Replace entire fake community with real Firestore-backed posts | Current implementation is a demo placeholder — users will immediately detect it's fake |
| M6 | Critical | Notifications | Build push notification infrastructure (FCM + in-app centre) | Session reminders, messages, and achievements all require notifications |
| M7 | Critical | Search | Replace all client-side search with Firestore queries | Fetching ALL coaches/venues and filtering in Dart breaks at 100+ records |
| M8 | Critical | Chat | Add pagination to message queries (limit + load more) | Chat with 1,000+ messages currently loads entire collection — will crash |
| M9 | Critical | Navigation | Fix GoRouter redirect to use Riverpod auth state instead of `FirebaseAuth.instance` directly | Inconsistent auth source causes redirect loops |
| M10 | Critical | Analytics | Fix Mission Control console to show real active user count | Currently shows fabricated data in admin dashboard |
| M11 | High | Dashboard | Replace all hardcoded KPI values and trends with real calculations | Every number on the dashboard is currently fabricated |
| M12 | High | Schedule | Wire up "View Details" and "Reschedule" buttons on upcoming session card | Both buttons are non-functional placeholders |
| M13 | High | Schedule | Add composite index for `playerId + dateTime` on sessions collection | Without this, player session queries will fail at scale |
| M14 | High | Performance | Add metric editing and deletion | Users cannot correct or remove wrong metric entries |
| M15 | High | Gamification | Build achievement unlock engine that reacts to platform events | Achievements are never actually unlocked — they just display as locked forever |
| M16 | High | Gamification | Wire XP earning to all player actions (session, booking, logging, posting) | XP is never actually incremented — `addPoints()` is never called |
| M17 | High | Gamification | Fix `LevelModel.getLevel` logic that always returns Mythic for points > 2001 | Every high-level player incorrectly shows Mythic |
| M18 | High | Coach Discovery | Decompose 588-line `coach_discovery_screen.dart` into smaller widgets | Single file handles search, filters, cards, booking, and time parsing |
| M19 | High | Coach Discovery | Fix time parsing to handle 12-hour/24-hour formats robustly | Current implementation splits strings and fails on edge cases |
| M20 | High | Coach Discovery | Add coach detail screen (separate from booking sheet) | Users cannot learn about a coach before booking |
| M21 | High | Chat | Cache user profiles to avoid N+1 Firestore reads per chat tile | Each chat tile makes a separate user profile request |
| M22 | High | Chat | Fix "Online" status to use real presence data instead of hardcoded | Currently shows every user as "Online" |
| M23 | High | Performance | Decompose 593-line `performance_tab.dart` into separate widgets | Single file handles chart, logging, filters, session list |
| M24 | High | Profile | Sync profile changes across all role collections | Changing name in profile only updates `users/` not `players/` or `coaches/` |
| M25 | High | Contracts | Fix financial calculation: `totalAmount = amount * 1.10` is mathematically wrong | Platform fee + opportunity fee - savings calculation makes no sense |
| M26 | High | Contracts | Show contracts where player is party B (not just party A) | Players only see contracts they initiated |
| M27 | High | Video Analysis | Rename "AI Coach" to "Video Analysis" or integrate actual AI | Current name is false advertising |
| M28 | High | Venue | Add composite index for player session queries | Missing index causes query failures |
| M29 | High | Dashboard | Remove duplicate `playerProvider` watches (parent watches same stream as children) | Every dashboard section re-subscribes to the same player stream |

---

## Should Have (Phase 2 — Pilot Launch)

| ID | Priority | Module | Item |
|----|----------|--------|------|
| S1 | High | Search | Implement Firestore `array-contains` and `>=` text search for coaches and venues |
| S2 | High | Venue | Add geolocation-based venue discovery (nearest first) |
| S3 | High | Venue | Replace placeholder venue images with actual photos |
| S4 | High | Venue | Add venue booking flow |
| S5 | High | Chat | Add media sharing in chat (image upload) |
| S6 | High | Notifications | Send push notifications for session reminders (24h, 1h before) |
| S7 | High | Notifications | Send push notifications for new messages |
| S8 | High | Notifications | Send push notifications for achievement unlocks |
| S9 | High | Performance | Add date range filter for performance charts |
| S10 | High | Performance | Add coach view of student metrics |
| S11 | High | Coach | Implement post-session rating system |
| S12 | High | Schedule | Show multiple upcoming sessions (not just the earliest one) |
| S13 | High | Schedule | Add full session detail screen |
| S14 | High | Schedule | Implement cancel booking flow with confirmation |
| S15 | High | Profile | Implement avatar photo upload via image picker |
| S16 | High | Profile | Add notification preferences screen |
| S17 | High | Gamification | Add level-up celebration animation |
| S18 | High | Gamification | Add more achievements (target: 20+ for MVP) |
| S19 | High | Community | Add image upload for community posts |
| S20 | High | Community | Add like/unlike functionality |
| S21 | High | Community | Add comments on posts |
| S22 | Medium | Parent | Implement linked children management |
| S23 | Medium | Parent | Add child progress view (metrics, attendance, achievements) |
| S24 | Medium | Parent | Allow booking sessions for children |
| S25 | Medium | Academy | Build batch management CRUD |
| S26 | Medium | Academy | Implement coach assignment to batches |
| S27 | Medium | Academy | Build coach placement pipeline |
| S28 | Medium | Academy | Implement job posting and application workflow |
| S29 | Medium | Admin | Build user management (view, suspend, ban) |
| S30 | Medium | Admin | Build revenue dashboard |
| S31 | Medium | Admin | Implement content moderation for community |
| S32 | Medium | UI | Add pull-to-refresh on all scrollable screens |
| S33 | Medium | UI | Add offline indicator |
| S34 | Medium | UI | Add onboarding flow for first-time users per role |
| S35 | Medium | Access | Add `Semantics` widgets across all screens |
| S36 | Medium | Access | Ensure all touch targets meet 44px minimum |
| S37 | Medium | Access | Verify and fix contrast ratios |
| S38 | Medium | Testing | Unit tests for all services |
| S39 | Medium | Testing | Widget tests for all critical screens |
| S40 | Medium | Testing | Integration test: signup → complete profile → book session → attend → earn XP |

---

## Could Have (Phase 3 — Post-Pilot)

| ID | Priority | Module | Item |
|----|----------|--------|------|
| C1 | Medium | Community | Verified achievement auto-posts (system-generated posts when player unlocks achievement) |
| C2 | Medium | Community | User follow system |
| C3 | Medium | Community | Content reporting and moderation UI |
| C4 | Medium | Gamification | Leaderboard (weekly, monthly, all-time) |
| C5 | Medium | Gamification | Achievement rewards (XP bonuses, visual badges, platform discounts) |
| C6 | Medium | Gamification | Streak tracking for consecutive training days |
| C7 | Medium | Gamification | Season-based competitions with prizes |
| C8 | Medium | Video Analysis | Video upload to Firebase Storage |
| C9 | Medium | Video Analysis | Coach annotation tools on video frames |
| C10 | Medium | Video Analysis | Side-by-side before/after video comparison |
| C11 | Medium | Squad Goals | Goal completion celebrations and team notifications |
| C12 | Medium | Squad Goals | Coach-assigned team goals |
| C13 | Medium | Contracts | Contract creation flow for coach-player agreements |
| C14 | Medium | Contracts | Digital signature integration |
| C15 | Medium | Contracts | Escrow-based payment on contracts |
| C16 | Medium | Payments | Digital wallet with balance |
| C17 | Medium | Payments | Multiple payment methods (UPI, cards, net banking) |
| C18 | Medium | Payments | Subscription billing for recurring sessions |
| C19 | Medium | Payments | Automated coach payouts |
| C20 | Medium | Venue | Real-time availability calendar |
| C21 | Medium | Venue | Recurring booking for weekly sessions |
| C22 | Medium | Venue | Map view with venue markers (Google Maps) |
| C23 | Medium | Session | Group sessions and team training |
| C24 | Medium | Session | Session templates |
| C25 | Medium | Session | Post-session coach feedback form |
| C26 | Medium | Attendance | QR code check-in at venue |
| C27 | Medium | Attendance | Geofenced attendance verification |
| C28 | Medium | Attendance | No-show penalty system |
| C29 | Low | Academy | Parent communication portal |
| C30 | Low | Academy | Marketing campaign management |
| C31 | Low | Academy | Discount coupon management |
| C32 | Low | Coach | Session recording and playback |
| C33 | Low | UI | Multi-language support (i18n — Hindi, Marathi for Pune pilot) |
| C34 | Low | UI | Animated state transitions (empty → loaded → error) |
| C35 | Low | Admin | A/B testing framework |
| C36 | Low | Admin | Support ticket system |
| C37 | Low | Admin | Feature flags management |
| C38 | Low | Admin | Automated abuse detection (keyword filtering, spam detection) |
| C39 | Low | Analytics | Automated weekly progress reports delivered via email |
| C40 | Low | Analytics | Coach effectiveness report (aggregate student improvement) |
| C41 | Low | Analytics | Export performance data to PDF/CSV |
| C42 | Low | Auth | Phone number authentication |
| C43 | Low | Auth | Multi-factor authentication for admin accounts |
| C44 | Low | Venue | Dynamic pricing for venues based on demand |

---

## Future (Phase 4 — Dream)

| ID | Module | Item |
|----|--------|------|
| F1 | AI Coach | Real-time pose estimation during video recording |
| F2 | AI Coach | Automated technique scoring (batting stance, bowling action, running form) |
| F3 | AI Coach | AI-generated drill recommendations based on performance gaps |
| F4 | AI Coach | Injury risk prediction from workload and performance metrics |
| F5 | AI | Personalized training plan generation from goals and history |
| F6 | AI | Smart coach-student matching (learning style, goals, personality) |
| F7 | AI | Dynamic session pricing based on demand, coach rating, and time |
| F8 | AI | Enrolment forecasting for academies |
| F9 | AI | Automated content moderation (image and text) |
| F10 | AI | Fraud detection in payments and booking patterns |
| F11 | AI | User churn prediction with automated retention campaigns |
| F12 | AI | Intelligent support ticket routing and auto-resolution |
| F13 | Integration | Wearable device sync (Fitbit, Apple Watch, Garmin) |
| F14 | Integration | Calendar sync (Google Calendar, Outlook, Apple Calendar) |
| F15 | Integration | School sports association data integration |
| F16 | Integration | College recruitment portal (verified athlete profiles for scouts) |
| F17 | Integration | Sponsorship marketplace (brands discover athletes by performance) |
| F18 | Scale | Full-text search via Algolia or Typesense |
| F19 | Scale | CDN for video and image content |
| F20 | Scale | Multi-region Firebase deployment for low-latency across India |
| F21 | Platform | Public athlete profile pages (shareable links) |
| F22 | Platform | NFT-style digital achievement collectibles |
| F23 | Platform | Progressive Web App (PWA) for mobile web |
| F24 | Platform | Coach certification verification system |
| F25 | Platform | Public API for third-party integrations |
| F26 | Platform | White-label solution for academies |

---

## Technical Debt (Must Fix, Non-Feature)

| ID | Module | Item | Impact |
|----|--------|------|--------|
| T1 | Architecture | Eliminate duplicate `_parseTimestamp` function across 5 model files | Violates DRY — duplicated in coach_model, player_model, chat_model, academy_model, squad_goals_service |
| T2 | Architecture | Eliminate dual design system: choose between `core/theme/` and `design_system/` | Inconsistent imports and visual bugs — some screens use one, some the other |
| T3 | Architecture | Remove unused barrel exports from `design_system/design_system.dart` | Over 50 dead exports — increases bundle size and confuses developers |
| T4 | Architecture | Decompose `auth_service.dart` (220 lines handles auth + coupons + admin tasks + active users) | Violates Single Responsibility Principle |
| T5 | Architecture | Decompose `PremiumShell` (566 lines) into smaller widgets | Single file handles sidebar, drawer, bottom nav, content area |
| T6 | Architecture | Decompose `providers.dart` (234 lines, 30+ providers) into domain-specific provider files | Single provider file scales poorly |
| T7 | Performance | Add query limits to all Firestore stream providers (no unbounded reads) | Every stream provider reads entire collections without limit |
| T8 | Performance | Add Firestore pagination to all list providers | Currently no load-more or infinite scroll pattern |
| T9 | Performance | Eliminate `allUsersProvider` reads throughout the app | Fetches entire user collection — used by community, chat, and dashboard |
| T10 | Performance | Add caching layer for frequently accessed data (user profiles, coach list) | Same data fetched repeatedly across different screens |
| T11 | Security | Harden Firestore security rules — remove wildcard catch-all rule | Current rules allow any authenticated user to read/write any collection |
| T12 | Security | Add Firestore validation rules for all document writes | No server-side validation — client could write invalid data |
| T13 | Security | Remove API keys from Firebase config committed to repository | API keys in `firebase_options.dart` are exposed |
| T14 | Testing | Remove dependency on Firebase from unit tests | Current test calls Firebase directly — fails in test environments |
| T15 | Testing | Add Firebase emulator support for testing | No emulator configuration exists |
| T16 | UI | Eliminate splash screen race condition (timer vs auth stream) | Two competing async operations cause unreliable splash duration |
| T17 | UI | Add error boundary and crash reporting | No crash reporting configured |
