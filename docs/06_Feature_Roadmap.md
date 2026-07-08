# 06 — Feature Roadmap

## Legend

| Tag | Meaning |
|-----|---------|
| **MVP** | Must-have for initial launch. Without these, the product has no value. |
| **Launch** | Required for the Pune pilot launch. Completes the core experience. |
| **Future** | Post-pilot, pre-Series A. Expands value for existing users. |
| **Dream** | Post-Series A, long-term vision. Game-changing but dependent on scale. |

---

## Phase 1: Foundation (MVP)

| # | Module | Feature | Tag |
|---|--------|---------|-----|
| 1 | Authentication | Email/password signup and login | MVP |
| 2 | Authentication | Google OAuth sign-in | MVP |
| 3 | Authentication | Password reset | MVP |
| 4 | Authentication | Role selection during signup (Player, Coach, Academy, Parent) | MVP |
| 5 | Authentication | Auth state persistence (auto-login) | MVP |
| 6 | Authentication | Session management (logout) | MVP |
| 7 | Player Dashboard | Player profile with name, avatar, level, XP, rank | MVP |
| 8 | Player Dashboard | Upcoming session card | MVP |
| 9 | Player Dashboard | Quick actions (Book Coach, Performance, etc.) | MVP |
| 10 | Player Dashboard | XP progress bar | MVP |
| 11 | Player Dashboard | KPI overview (sessions, hours, achievements, ranking) | MVP |
| 12 | Player Dashboard | Performance trend chart | MVP |
| 13 | Player Dashboard | Achievement badges (horizontal scroll) | MVP |
| 14 | Player Dashboard | Activity timeline | MVP |
| 15 | Coach Dashboard | Coach profile with specialization, rating, experience, rate | MVP |
| 16 | Coach Dashboard | Upcoming sessions list | MVP |
| 17 | Coach Dashboard | Student list | MVP |
| 18 | Coach Discovery | Browse coaches with rating, experience, specialization | MVP |
| 19 | Coach Discovery | Filter by sport, location, rating | MVP |
| 20 | Coach Discovery | Book session flow (date, time, sport) | MVP |
| 21 | Session | Create session (coach) | MVP |
| 22 | Session | Book session (player) | MVP |
| 23 | Session | Session list with status | MVP |
| 24 | Performance | Log performance metrics (speed, stamina, etc.) | MVP |
| 25 | Performance | Chart with metric selection | MVP |
| 26 | Gamification | XP earning (session attendance) | MVP |
| 27 | Gamification | Level system (6 levels: Rookie → Mythic) | MVP |
| 28 | Gamification | Rank system (5 ranks: Bronze → Diamond) | MVP |
| 29 | Gamification | Achievement definitions (6 achievements) | MVP |
| 30 | Achievements | Achievement display with locked/unlocked states | MVP |
| 31 | Chat | Direct messaging between player and coach | MVP |
| 32 | Chat | Chat list with last message preview | MVP |
| 33 | Chat | Real-time message updates (Firestore streams) | MVP |
| 34 | Chat | Unread count badges | MVP |
| 35 | Chat | New conversation creation | MVP |
| 36 | Venue Discovery | Venue list with sport filter | MVP |
| 37 | Venue Discovery | Venue detail with amenities, pricing, location | MVP |
| 38 | Navigation | Role-based shell (Player, Coach, Academy, Parent, Admin) | MVP |
| 39 | Navigation | Bottom navigation (phone) | MVP |
| 40 | Navigation | Sidebar navigation (desktop) | MVP |
| 41 | Navigation | GoRouter with auth redirect | MVP |
| 42 | UI | Dark theme | MVP |
| 43 | UI | Light theme | MVP |
| 44 | UI | Responsive layout (phone, tablet, desktop) | MVP |
| 45 | UI | Loading states (shimmer) | MVP |
| 46 | UI | Error states with retry | MVP |
| 47 | UI | Empty states | MVP |

---

## Phase 2: Pilot Launch (Launch)

| # | Module | Feature | Tag |
|---|--------|---------|-----|
| 48 | Firebase | Real Firebase project setup (replace `auth-for-docs`) | Launch |
| 49 | Firebase | Firestore security rules hardening | Launch |
| 50 | Authentication | Email verification | Launch |
| 51 | Authentication | Phone number authentication | Launch |
| 52 | Authentication | Auth loading state (fix `authLoadingProvider`) | Launch |
| 53 | Player Dashboard | Real KPI calculations (replace fabricated data) | Launch |
| 54 | Player Dashboard | Wire up "View Details" and "Reschedule" buttons | Launch |
| 55 | Player Dashboard | Pull-to-refresh | Launch |
| 56 | Performance | Metric editing and deletion | Launch |
| 57 | Performance | Date range filter for charts | Launch |
| 58 | Performance | Coach view of student metrics | Launch |
| 59 | Coach Dashboard | Real earnings calculation with payout data | Launch |
| 60 | Coach Dashboard | Create session with venue selection | Launch |
| 61 | Coach Dashboard | Mark attendance for sessions | Launch |
| 62 | Coaching | Coach rating system (post-session) | Launch |
| 63 | Schedule | Multiple upcoming sessions (not just first) | Launch |
| 64 | Schedule | Session detail screen | Launch |
| 65 | Schedule | Cancel booking flow with confirmation | Launch |
| 66 | Schedule | Calendar view (week/month) | Launch |
| 67 | Search | Firestore query-based search (replace client-side filter) | Launch |
| 68 | Search | Server-side text search for coaches and venues | Launch |
| 69 | Chat | Message pagination (limit + load more) | Launch |
| 70 | Chat | Push notifications for new messages | Launch |
| 71 | Chat | Media sharing (images in chat) | Launch |
| 72 | Notifications | Push notification infrastructure (FCM) | Launch |
| 73 | Notifications | Session reminder notifications | Launch |
| 74 | Notifications | Achievement unlock notifications | Launch |
| 75 | Notifications | Booking confirmation notifications | Launch |
| 76 | Notifications | In-app notification centre | Launch |
| 77 | Gamification | Achievement unlock engine (event-driven, not manual) | Launch |
| 78 | Gamification | XP earning across all actions (booking, logging, posting) | Launch |
| 79 | Gamification | Level-up celebration animation | Launch |
| 80 | Parent Dashboard | Linked children management | Launch |
| 81 | Parent Dashboard | Child progress view (metrics, attendance, achievements) | Launch |
| 82 | Parent Dashboard | Book session for child | Launch |
| 83 | Academy Dashboard | Batch management | Launch |
| 84 | Academy Dashboard | Coach assignment to batches | Launch |
| 85 | Academy Dashboard | Coach placement pipeline | Launch |
| 86 | Academy Dashboard | Job posting and applications | Launch |
| 87 | Profile | Avatar photo upload (image picker + storage) | Launch |
| 88 | Profile | Name/email/phone editing with cross-collection sync | Launch |
| 89 | Profile | Notification preferences screen | Launch |
| 90 | Profile | Help and support with dynamic content | Launch |
| 91 | Venue Discovery | Geolocation-based sorting (nearest first) | Launch |
| 92 | Venue Discovery | Venue booking flow | Launch |
| 93 | Venue Discovery | Real venue photos (not placeholder gradients) | Launch |
| 94 | Admin Panel | User management (view, suspend, ban) | Launch |
| 95 | Admin Panel | Revenue dashboard | Launch |
| 96 | Admin Panel | Content moderation for community | Launch |
| 97 | Performance | N+1 query fixes (playerProvider in coach dashboard) | Launch |
| 98 | Performance | Composite index for `playerId + dateTime` in sessions | Launch |
| 99 | Performance | Chat N+1 query fix (user profile per chat tile) | Launch |
| 100 | UI | Offline indicator | Launch |
| 101 | UI | Accessibility pass (Semantics, touch targets, contrast) | Launch |
| 102 | Testing | Unit tests for services | Launch |
| 103 | Testing | Widget tests for core screens | Launch |
| 104 | Testing | Integration tests for critical flows (signup → book session) | Launch |

---

## Phase 3: Growth & Engagement (Future)

| # | Module | Feature | Tag |
|---|--------|---------|-----|
| 105 | Community | Real Firestore-based posts (replace fake mock data) | Future |
| 106 | Community | Image upload for posts | Future |
| 107 | Community | Like/unlike posts | Future |
| 108 | Community | Comments on posts | Future |
| 109 | Community | Verified achievement auto-posts | Future |
| 110 | Community | Content reporting and moderation | Future |
| 111 | Community | User follow system | Future |
| 112 | Gamification | Leaderboard (weekly/monthly/all-time) | Future |
| 113 | Gamification | Achievement rewards (XP bonuses, badges, discounts) | Future |
| 114 | Gamification | Streak tracking (consecutive training days) | Future |
| 115 | Gamification | Season-based competition with prizes | Future |
| 116 | Video Analysis | Video upload and storage | Future |
| 117 | Video Analysis | Coach annotation on video frames | Future |
| 118 | Video Analysis | Side-by-side comparison (before/after) | Future |
| 119 | Squad Goals | Goal progress tracking | Future |
| 120 | Squad Goals | Team-based challenges | Future |
| 121 | Squad Goals | Goal completion celebrations | Future |
| 122 | Contracts | Contract creation for coach-player agreements | Future |
| 123 | Contracts | Digital signatures | Future |
| 124 | Contracts | Escrow-based payment on contracts | Future |
| 125 | Payments | Wallet with balance and transaction history | Future |
| 126 | Payments | Multiple payment methods (UPI, cards) | Future |
| 127 | Payments | Subscription billing for recurring sessions | Future |
| 128 | Payments | Automated coach payouts | Future |
| 129 | Venue | Real-time availability calendar | Future |
| 130 | Venue | Recurring booking (weekly sessions) | Future |
| 131 | Venue | Map view with venue markers | Future |
| 132 | Academy | Parent portal for communication | Future |
| 133 | Academy | Marketing campaigns and coupons | Future |
| 134 | Academy | Coach task management (milestones) | Future |
| 135 | Session | Group sessions and team training | Future |
| 136 | Session | Session templates for recurring use | Future |
| 137 | Session | Session reviews and coach feedback | Future |
| 138 | Attendance | QR code check-in at venue | Future |
| 139 | Attendance | Automated attendance via geofencing | Future |
| 140 | Attendance | No-show penalty system | Future |
| 141 | UI | Multi-language support (i18n) | Future |
| 142 | UI | Animations for state transitions | Future |
| 143 | UI | Onboarding flow for new users | Future |
| 144 | Admin | A/B testing framework | Future |
| 145 | Admin | Support ticket system | Future |
| 146 | Admin | Feature flags management | Future |
| 147 | Admin | Automated abuse detection | Future |
| 148 | Analytics | Automated weekly progress reports (email) | Future |
| 149 | Analytics | Coach effectiveness report | Future |
| 150 | Analytics | Export performance data to PDF/CSV | Future |

---

## Phase 4: AI & Scale (Dream)

| # | Module | Feature | Tag |
|---|--------|---------|-----|
| 151 | AI Coach | Real-time pose estimation during recording | Dream |
| 152 | AI Coach | Automated technique scoring (batting, bowling, running) | Dream |
| 153 | AI Coach | AI-generated drill recommendations | Dream |
| 154 | AI Coach | Injury risk prediction from workload | Dream |
| 155 | AI | Personalized training plan generation | Dream |
| 156 | AI | Coach-student smart matching algorithm | Dream |
| 157 | AI | Dynamic pricing for sessions based on demand | Dream |
| 158 | AI | Enrolment forecasting for academies | Dream |
| 159 | AI | Automated content moderation | Dream |
| 160 | AI | Fraud detection in payments | Dream |
| 161 | AI | Churn prediction and intervention | Dream |
| 162 | AI | Intelligent support ticket routing | Dream |
| 163 | Integration | Wearable device sync (smartwatch, fitness band) | Dream |
| 164 | Integration | Calendar sync (Google Calendar, Apple Calendar) | Dream |
| 165 | Integration | School sports association integration | Dream |
| 166 | Integration | College recruitment portal | Dream |
| 167 | Integration | Sponsorship marketplace | Dream |
| 168 | Scale | Full-text search (Algolia/Typesense) | Dream |
| 169 | Scale | CDN for video and image content | Dream |
| 170 | Scale | Multi-region Firebase deployment | Dream |
| 171 | Platform | Public athlete profiles (shareable links) | Dream |
| 172 | Platform | NFT-style digital achievement collectibles | Dream |
| 173 | Platform | Mobile web version (PWA) | Dream |
| 174 | Platform | Coach certification verification system | Dream |
| 175 | Platform | API for third-party integrations | Dream |
