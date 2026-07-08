# Phase Roadmap — SportsEco

> **Document Purpose:** Define the phased roll-out plan for SportsEco across MVP, V1, V2, V3, and Future horizons. Each phase includes specific features, rationale, target metrics, dependencies, and estimated timelines. This is the execution blueprint that translates product vision into shippable increments.

---

## Overview

| Phase | Code Name | Timeline | Focus | Target Users | Key Metric |
|-------|-----------|----------|-------|--------------|------------|
| **MVP** | "First Touch" | Months 1-3 | Core experience validation | Players, Coaches | 1K MAU, 50 sessions booked |
| **V1** | "Eco System" | Months 4-8 | Ecosystem completeness | +Academies, Parents | 5K MAU, 100 coaches onboarded |
| **V2** | "Intelligence" | Months 9-14 | AI & gamification engine | All roles | 25K MAU, 40% MoM retention |
| **V3** | "Marketplace" | Months 15-20 | Commerce & monetization | +Venue Partners | 100K MAU, 5Cr GMV/quarter |
| **Future** | "Scale" | 21+ months | Expansion & platform | All + Enterprise | 5M MAU, 500Cr GMV |

---

## MVP — "First Touch" (Months 1-3)

### Philosophy
Ship the smallest possible system that proves SportsEco solves a real problem for players and coaches in Pune. No frills, no gamification, no AI — just a rock-solid session booking and management loop that works end-to-end.

### Features

#### Authentication & Onboarding (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Splash screen | ✅ Exists | — | Add branding animation |
| Login (email + Google) | ✅ Exists | — | — |
| Signup with role selection | ✅ Exists | — | Add phone number field |
| Forgot password | ✅ Exists | — | — |
| Role-based routing after login | ✅ Exists | — | Verify redirect flows |
| Onboarding wizard (first-time) | 🟡 Partial | 2 weeks | Add sport/location preference step |

#### Player Experience (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Player Dashboard | ✅ Exists | — | Add upcoming session count, quick actions |
| Coach Discovery (list) | 🟡 Partial | 1 week | Replace mock data with Firestore stream |
| Coach Profile (detail) | 🟡 Partial | 1 week | Add reviews section (static first) |
| Session Booking | ❌ Missing | 3 weeks | **Critical MVP feature** — see flow below |
| My Sessions list | ❌ Missing | 2 weeks | Filter: upcoming, past, cancelled |
| Session Detail screen | ❌ Missing | 1 week | Time, location, coach info, materials |
| Basic Profile (edit) | 🟡 Partial | 1 week | Add sports played, location |

**Session Booking Flow (MVP scope):**
1. Player discovers coach → views profile
2. Sees available time slots (coach manually sets)
3. Selects slot → confirms booking → notification sent to coach
4. Coach accepts/rejects → player notified
5. Session appears in "Upcoming Sessions" for both

#### Coach Experience (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Coach Dashboard | ✅ Exists | — | Add earnings summary, upcoming sessions |
| Create Session | 🟡 Partial | 2 weeks | Add time slot management, max capacity |
| Session Management | ❌ Missing | 2 weeks | Accept/reject/cancel sessions |
| Coach Profile (public) | 🟡 Partial | 1 week | Add certifications, specialties |
| Availability Calendar | ❌ Missing | 2 weeks | Weekly repeating schedule |

#### Core Infrastructure (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Firebase Auth wiring | ✅ Exists | — | — |
| Firestore collections | ✅ Exists | — | Add sessions collection |
| Riverpod providers | ✅ Exists | — | Add session providers |
| GoRouter setup | ✅ Exists | — | Add session routes |
| Design System components | ✅ Exists | — | — |

#### Design System (P0 — polish)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Glassmorphism cards | ✅ Exists | — | — |
| Shimmer loading | ✅ Exists | — | — |
| Empty states | ✅ Exists | — | — |
| Error states | ✅ Exists | — | — |
| Toast/Snackbar | ✅ Exists | — | — |
| Responsive layout (desktop) | ✅ Exists | — | — |
| Responsive layout (tablet) | ✅ Exists | — | — |
| Responsive layout (mobile) | ✅ Exists | — | — |

#### Chat (P1)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Chat List | ✅ Exists | — | — |
| Chat Detail | ✅ Exists | — | — |
| Initiate chat from booking | ❌ Missing | 1 week | Auto-create chat on booking accept |

#### Notifications (P1)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| FCM integration | ❌ Missing | 2 weeks | Booking confirmations, reminders |
| In-app notification center | ❌ Missing | 2 weeks | Using notifications collection |

### Out of Scope for MVP
- Payments (cash/Venmo handled offline)
- Venue booking
- Academy management
- Parent accounts
- Gamification
- Video analysis
- Community
- Admin panel

### MVP Success Metrics

| Metric | Target | How Measured |
|--------|--------|-------------|
| Monthly Active Users | 1,000 | Firebase Analytics |
| Sessions Booked | 50 | Firestore sessions count |
| Coach Onboarding | 20 | Coach collection count |
| Booking Completion Rate | >70% | Booked / initiated bookings |
| D7 Retention (Player) | >30% | Return within 7 days |
| NPS | >40 | In-app survey after 3rd session |
| Avg. Session Rating | >4.0/5 | Session reviews |

### MVP Technical Dependencies

1. **Sessions collection** must be added to Firestore schema
2. **Cloud Functions** for booking notifications (or client-side FCM)
3. **Indexes** for session queries (coachId + date, playerId + status)
4. **Security rules** hardening (see 05_FIREBASE_ARCHITECTURE.md)
5. **Storage rules** hardening

### MVP Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Low coach supply | High | Recruit 20 coaches before launch via partnerships |
| Booking UX confusing | Medium | User test with 10 players before launch |
| No payment = no commitment | Medium | Require phone verification, enforce cancellation policy |
| Pune not ready | Low | Survey 50 players in Pune first |

---

## V1 — "Eco System" (Months 4-8)

### Philosophy
Complete the core ecosystem by adding Academies, Parents, and Admin capabilities. Establish the economic loop: Players book coaches → Coaches earn income → Academies manage batches → Parents monitor progress → Admin oversees quality.

### Features

#### Academy Experience (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Academy Dashboard | ✅ Exists | — | Needs theme migration to design_system/ |
| Academy Profile | ❌ Missing | 2 weeks | Programs, facilities, location, photos |
| Batch Management | 🟡 Partial | 3 weeks | CRUD batches, assign coaches |
| Student Enrollment | ❌ Missing | 3 weeks | Request/accept/paid flows |
| Coach Management | ❌ Missing | 2 weeks | Invite coaches, approve, assign |
| Academy Analytics | ❌ Missing | 3 weeks | Enrollment, revenue, attendance |
| Placement Tracking | 🟡 Partial | 2 weeks | Student placement records |

#### Parent Experience (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Parent Dashboard | ✅ Exists | — | Needs theme migration |
| Link Child (Player) | ❌ Missing | 2 weeks | Request link, verify, approve |
| Child Dashboard view | ❌ Missing | 2 weeks | Read-only view of child's activity |
| Parent Reports | ❌ Missing | 3 weeks | Weekly progress, attendance, payments |
| Session Booking (on behalf of) | ❌ Missing | 2 weeks | Book for child |

#### Admin Panel (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Admin Dashboard | ✅ Exists | — | Needs theme migration |
| User Management | 🟡 Partial | 3 weeks | Search, ban, verify, role management |
| Content Moderation | ❌ Missing | 2 weeks | Report system, block content |
| Campaign Management | ✅ Exists | — | Use cases: Promo, Event, Notification |
| Admin Tasks | ✅ Exists | — | Assignment, tracking, completion |

#### Contracts & Payments (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Contract List | ✅ Exists | — | — |
| Contract Detail | ✅ Exists | — | — |
| Contract Creation | ❌ Missing | 3 weeks | Templates, negotiation, signing |
| Payment Integration (Razorpay) | ❌ Missing | 4 weeks | UPI, cards, netbanking |
| Wallet/Balance system | ❌ Missing | 3 weeks | Coach earnings, withdrawals |
| Revenue sharing % | ❌ Missing | 2 weeks | Platform fee configuration |

#### Coach Discovery (P1 → P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Search & Filter | 🟡 Partial | 2 weeks | By sport, location, rating, price |
| Reviews & Ratings | ❌ Missing | 2 weeks | Post-session review |
| Coach Verification Badge | ❌ Missing | 1 week | Document verification |
| Saved Coaches (Favorites) | ❌ Missing | 1 week | Bookmark for quick booking |

#### Community (P1)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Community Feed | 🟡 Partial | 2 weeks | Replace mock posts with real Firestore |
| Create Post | ❌ Missing | 1 week | Text + image posts |
| Like/Comment | ❌ Missing | 2 weeks | Engagement features |
| Post Types | ❌ Missing | 2 weeks | Achievement, Question, Highlight, Event |
| Sports-specific feeds | ❌ Missing | 1 week | Filter by sport category |

#### Session Enhancement (P1)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Recurring Sessions | ❌ Missing | 2 weeks | Weekly batch booking |
| Waitlist | ❌ Missing | 1 week | Auto-notify on cancellation |
| Session Reminders | ❌ Missing | 1 week | 24hr + 1hr before |
| Check-in/Check-out | ❌ Missing | 2 weeks | QR code or manual |

#### Notifications (P1 → P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| FCM Cloud Functions | ❌ Missing | 3 weeks | Booking, payment, reminder, admin alerts |
| Notification Preferences | ❌ Missing | 1 week | Per-type toggle |
| Email Notifications | ❌ Missing | 1 week | Via Firebase Extensions |

### V1 Out of Scope
- Video analysis
- Gamification (XP, levels, achievements)
- AI features
- Venue partner dashboard
- Advanced analytics / ML

### V1 Success Metrics

| Metric | Target |
|--------|--------|
| MAU | 5,000 |
| Academies onboarded | 20 |
| Coaches onboarded | 100 |
| Parents registered | 500 |
| Monthly sessions booked | 500 |
| Payment transactions | 200 |
| Platform GMV (monthly) | ₹5L |
| Coach repeat booking rate | >50% |
| Parent NPS | >45 |

### V1 Technical Dependencies

1. **Razorpay integration** — Payouts to coaches, subscription for academies
2. **Cloud Functions** for:
   - Payment webhooks
   - Notification dispatch
   - Contract signing
   - Parent-child linking verification
3. **New Indexes**: contracts, payments, reviews, notifications, community posts
4. **Security rules** — Role-based write rules for academies, parents
5. **theme migration** — Coach, Academy, Parent, Admin dashboards to `design_system/`

### V1 Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Payment integration delays | High | Start Razorpay integration month 4 |
| Academy onboarding friction | Medium | Dedicated onboarding team + phone support |
| Parent acquisition | Medium | Parents come through academies; incentivize schools |
| Coach quality drops with scale | High | Coach verification + rating system + admin review |

---

## V2 — "Intelligence" (Months 9-14)

### Philosophy
Transform SportsEco from a booking platform into an intelligent sports growth system. Gamification drives engagement and retention. AI delivers personalized coaching insights. Video analysis creates a new category of value for players and coaches.

### Features

#### Gamification System (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| XP System | ❌ Missing | 3 weeks | Track all earning actions |
| Levels & Ranks | ❌ Missing | 2 weeks | Per 08_GAMIFICATION_SYSTEM.md |
| Achievements (30+) | ❌ Missing | 4 weeks | 7 categories, badge UI |
| Daily Streaks | ❌ Missing | 2 weeks | Tiered bonuses |
| Weekly Missions | ❌ Missing | 2 weeks | 15 types, 3 difficulties |
| Monthly Goals | ❌ Missing | 2 weeks | 7 types |
| Season System | ❌ Missing | 3 weeks | Quarterly, free/premium track |
| Leaderboards | ❌ Missing | 3 weeks | 7 types (local, national, positional, etc.) |
| Coach Reputation | ❌ Missing | 2 weeks | Bronze → Diamond tiers |
| Academy Reputation | ❌ Missing | 2 weeks | Local → Elite tiers |
| Rewards Store | ❌ Missing | 4 weeks | Redeem XP for perks, discounts |

#### Coach Reputation & Rewards

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Bronze → Diamond tiers | ❌ Missing | 2 weeks | Based on sessions, ratings, retention |
| Tier benefits | ❌ Missing | 1 week | Higher visibility, lower platform fee |
| Milestone badges | ❌ Missing | 2 weeks | 100 sessions, 5-star avg, etc. |

#### Squad Goals (P1 → P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Squad Goal Creation | ✅ Exists | — | — |
| Goal Tracking | ✅ Exists | — | — |
| Team-based goals | ❌ Missing | 2 weeks | Shared squad progression |
| Goal rewards | ❌ Missing | 1 week | XP bonuses on completion |
| Coach-assigned goals | ❌ Missing | 1 week | Coach creates goals for players |

#### Video Analysis (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Video Upload | ✅ Exists | — | — |
| Analysis Results Display | ✅ Exists | — | — |
| AI Processing Pipeline | ❌ Missing | 6 weeks | **Critical** — replace stub |
| Sport-specific models (7 sports) | ❌ Missing | 8 weeks | Cricket bowling, football penalty, etc. |
| Coach-in-the-loop review | ❌ Missing | 3 weeks | Coach marks up, adds audio |
| Frame-by-frame annotation | ❌ Missing | 3 weeks | Drawing tools, timestamps |
| Progress over time | ❌ Missing | 2 weeks | Compare videos across sessions |
| Share analysis | ❌ Missing | 1 week | Export, share with coach/parent |

**AI Pipeline Technical Plan:**
1. MediaPipe Pose for skeleton tracking (all sports)
2. Custom TensorFlow models per sport (trained on Indian sports data)
3. Google Cloud Video Intelligence API for scene detection
4. Cloud Functions trigger on Storage upload → enqueue analysis task
5. Results written to `videoAnalysis` collection with pose landmarks, scores, recommendations
6. Coach review interface built in Flutter with syncfusion or custom canvas

#### AI Features (P1)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| AI Coach Assistant | ❌ Missing | 4 weeks | Session intelligence, business insights |
| AI Player Assistant | ❌ Missing | 4 weeks | Training tips, career guidance |
| AI Session Planner | ❌ Missing | 3 weeks | Optimal session structure |
| Performance Insights | ❌ Missing | 4 weeks | Trend detection, predictive analytics |
| Academy Analytics | ❌ Missing | 3 weeks | Operational, marketing intelligence |
| Attendance Prediction | ❌ Missing | 3 weeks | No-show risk, overbooking prevention |
| Training Suggestions (daily) | ❌ Missing | 3 weeks | Personalized drill recommendations |
| Parent AI Reports | ❌ Missing | 3 weeks | Weekly AI-generated progress reports |

#### Performance/Analytics (P1)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Player Metrics Dashboard | ✅ Exists | — | — |
| Trend Charts | ❌ Missing | 3 weeks | Progress over weeks/months |
| Comparison (vs. peers) | ❌ Missing | 2 weeks | Anonymized benchmarks |
| Coach Performance Dashboard | ❌ Missing | 3 weeks | Acceptance rate, rating trends, earnings |
| Export Reports | ❌ Missing | 1 week | PDF/CSV |

### V2 Success Metrics

| Metric | Target |
|--------|--------|
| MAU | 25,000 |
| DAU/MAU ratio | >25% |
| Monthly retention (M1, M3, M6) | >60%, >40%, >25% |
| Gamification engagement (% active) | >60% of users engage weekly |
| Video analyses completed | 500/month |
| AI feature usage | >30% of active users |
| Coach NPS with AI tools | >50 |
| Sessions booked/month | 5,000 |
| Platform GMV (monthly) | ₹25L |

### V2 Technical Dependencies

1. **TensorFlow/MediaPipe integration** — Native module or API service
2. **Cloud Functions** for:
   - Video analysis pipeline
   - Gamification event processing
   - AI report generation
   - Leaderboard computation (scheduled)
3. **New Firestore collections**: gameEvents, dailyMissions, userProgress, seasons, leaderboards, rewards, achievementProgress, aiAnalyses
4. **New Indexes** — All gamification query patterns
5. **Cloud Tasks / PubSub** — Async video processing queue
6. **Storage** — Video storage hierarchy (raw, analyzed, thumbnails)

### V2 Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Video analysis quality low | High | Start with simple pose detection, iterate |
| Gamification feels gimmicky | Medium | Design rewards that have real value (discounts, visibility) |
| AI feature scope too large | High | Rank AI features, ship top 3 first |
| Storage costs for video | Medium | Compress uploads, auto-delete raw after 30 days, CDN |
| Model accuracy for Indian sports | Medium | Partner with sports science university for training data |

---

## V3 — "Marketplace" (Months 15-20)

### Philosophy
Activate the Venue Partner role and build a true multisided marketplace. Players and coaches book venues. Academies list programs. Monetization scales through platform fees, subscriptions, and premium features.

### Features

#### Venue Partner Experience (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Venue Partner Dashboard | ❌ Missing | 3 weeks | New dashboard — venue analytics |
| Venue Registration | ❌ Missing | 2 weeks | Location, photos, amenities, pricing |
| Venue Availability Calendar | ❌ Missing | 3 weeks | Hourly/daily/slot-based booking |
| Booking Calendar | ❌ Missing | 3 weeks | Visual calendar with booked/available |
| Venue Session Check-in | ❌ Missing | 2 weeks | QR code scanner |
| Revenue Dashboard | ❌ Missing | 2 weeks | Daily/weekly/monthly earnings |
| Venue Analytics | ❌ Missing | 3 weeks | Utilization %, peak hours, popular sports |
| Multi-sport configuration | ❌ Missing | 2 weeks | Different courts, different pricing |

#### Venue Discovery (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Venue List | ✅ Exists | — | Add map view |
| Venue Detail | ✅ Exists | — | Add booking flow |
| Venue Search | 🟡 Partial | 2 weeks | Location, sport, date, amenities |
| Map Integration | ❌ Missing | 3 weeks | Google Maps, proximity search |
| Venue Reviews | ❌ Missing | 2 weeks | Post-visit rating |
| Amenity Filters | ❌ Missing | 1 week | Parking, changing rooms, equipment |

#### Venue Booking (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Slot Selection | ❌ Missing | 3 weeks | Visual time slot picker |
| Booking Confirmation | ❌ Missing | 1 week | Auto-confirm for self-booked slots |
| Payment at Booking | ❌ Missing | 2 weeks | Pay to lock slot |
| Cancellation & Refund | ❌ Missing | 2 weeks | With penalty rules |
| Recurring Venue Booking | ❌ Missing | 2 weeks | Weekly slot for coaches |

#### Marketplace Features (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Platform Fee Engine | ❌ Missing | 3 weeks | Configurable % per service type |
| Promo Codes & Coupons | ✅ Exists | — | Admin-managed campaigns |
| Subscription Plans | ❌ Missing | 4 weeks | Coach/ Academy monthly plans |
| Premium Listings | ❌ Missing | 2 weeks | Pay for top placement |
| Featured Coaches/Academies | ❌ Missing | 2 weeks | Sponsored visibility |

#### Coach Jobs & Placements (P1)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Job Listings | ✅ Exists | — | — |
| Job Applications | ✅ Exists | — | — |
| Academy Placement | 🟡 Partial | 2 weeks | Track alumni placements |
| Coach Recruitment | ❌ Missing | 3 weeks | Academy can post jobs, coach can apply |
| Skill Verification | ❌ Missing | 2 weeks | Third-party certification integration |

#### Enhanced Admin (P0)

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| Transaction Monitoring | ❌ Missing | 3 weeks | All payments, refunds, disputes |
| Revenue Dashboard | ❌ Missing | 2 weeks | Platform revenue, projections |
| Dispute Resolution | ❌ Missing | 3 weeks | Ticket system for payment/session disputes |
| Fraud Detection | ❌ Missing | 4 weeks | Anomaly detection on bookings/payments |
| Compliance Dashboard | ❌ Missing | 2 weeks | KYC status, tax documents |

### V3 Success Metrics

| Metric | Target |
|--------|--------|
| MAU | 100,000 |
| Venue Partners | 100 |
| Venue Bookings/month | 10,000 |
| Total Sessions/month | 20,000 (venue + coach) |
| Platform GMV (monthly) | ₹1Cr |
| Platform Revenue (monthly) | ₹10L (10% take rate) |
| Subscription Revenue | ₹2L/month |
| Venue Utilization Rate | >60% |
| Marketplace NPS | >50 |

### V3 Technical Dependencies

1. **Google Maps SDK** — Venue discovery, proximity search
2. **Payment Payouts** — Automated weekly payouts to venue partners
3. **Scheduling Engine** — Conflict detection, double-booking prevention
4. **Cloud Functions** for:
   - Venue booking confirmation
   - Payout calculations
   - Promo code validation
   - Subscription billing (monthly)
5. **New Indexes** — Venue booking queries, payout history, subscription status
6. **Revenue Analytics Dashboard** — Aggregated views, export

### V3 Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Venue partner adoption | High | Incentivize first 50 venues with 0% platform fee for 3 months |
| Double-booking bugs | Critical | Pessimistic locking on slot selection |
| Payment disputes | Medium | Clear T&C, escrow hold until session completed |
| Marketplace chicken-egg | High | Venue supply before demand — onboard venues with existing traffic |
| Regulatory (GST, TDS) | High | CA consultation early, automated tax calculation |

---

## Future — "Scale" (Months 21+)

### Philosophy
Expand beyond Pune to top 10 Indian cities, then SEA, then global. Build enterprise offerings (schools, leagues, federations). Become the operating system for grassroots sports.

### Features

#### Geographic Expansion

| Phase | Cities | Timeline | Preparation |
|-------|--------|----------|-------------|
| 1 | Mumbai, Delhi-NCR, Bangalore | M21-M23 | Localized content, language support |
| 2 | Hyderabad, Chennai, Kolkata, Ahmedabad | M24-M26 | Regional language UI, local payment methods |
| 3 | Pune, Lucknow, Jaipur, plus 20 tier-2 | M27-M30 | Offline-capable mode, low-bandwidth optimization |
| 4 | SEA (Singapore, Malaysia, Thailand, Indonesia) | M31-M36 | Multi-currency, local regulations, SEA sports |
| Global | Middle East, Africa, LatAm | M37+ | Regional partnerships, localization v2 |

#### Enterprise & B2B

| Feature | Effort | Description |
|---------|--------|-------------|
| School Partnerships | 3 months | White-label dashboards for schools |
| League Management | 4 months | Tournament bracket, fixtures, results |
| Sports Federation Integration | 3 months | Certification tracking, talent scouting |
| Corporate Wellness | 2 months | Employee sports programs |
| API Platform | 4 months | Third-party integration APIs |

#### Platform Features

| Feature | Effort | Description |
|---------|--------|-------------|
| Multi-language (10+ Indian languages) | 3 months | Flutter i18n, RTL support |
| Offline Mode | 4 months | Local SQLite, sync when online |
| Progressive Web App | 2 months | Lite version for low-end devices |
| Dark Mode | ✅ Exists | Already implemented |
| Accessibility (WCAG 2.1 AA) | 3 months | Screen reader, contrast, navigation |
| AI Coach (Full) | 6 months | Real-time coaching during sessions via AR |
| Wearable Integration | 4 months | Smartwatch heart rate, step count |
| Live Streaming | 5 months | Pay-per-view coaching sessions |
| NFT Certificates | 3 months | Achievement verification on blockchain |
| Token Economy | 6 months | SportsEco coin for platform transactions |

#### Advanced Security & Compliance

| Feature | Effort | Description |
|---------|--------|-------------|
| SOC 2 Certification | 6 months | Enterprise readiness |
| GDPR / DPDP Compliance | 3 months | Data protection for global users |
| End-to-End Encryption (Chat) | 2 months | Signal protocol |
| Biometric Authentication | 2 weeks | Fingerprint, face ID |
| Advanced Fraud Detection | 3 months | ML-based booking/payment anomaly detection |

### Future Success Metrics

| Metric | Target (Year 3) | Target (Year 5) |
|--------|----------------|----------------|
| MAU | 500,000 | 5,000,000 |
| Cities | 10 | 50+ (Global) |
| Venue Partners | 1,000 | 10,000 |
| Coaches | 5,000 | 50,000 |
| Academies | 500 | 5,000 |
| Monthly GMV | ₹5Cr | ₹50Cr |
| Annual Revenue | ₹6Cr | ₹60Cr |
| Enterprise Clients | 50 | 500 |
| Employee Count | 50 | 200 |

---

## Dependency Map

```
MVP ──────────────────────────────────────────────┐
  ├── Auth & Onboarding                           │
  ├── Player + Coach core loop                    │
  └── Basic Chat                                  │
                                                  │
V1 ──────────────────────────────────────────────┤
  ├── Academy features ──── depends on: ──── MVP │
  ├── Parent features ──── depends on: ──── MVP  │
  ├── Admin panel ──── depends on: ──── MVP      │
  ├── Payments ──── depends on: ──── Academies   │
  └── Contracts ──── depends on: ──── Payments   │
                                                  │
V2 ──────────────────────────────────────────────┤
  ├── Gamification ──── depends on: ──── V1      │
  ├── Video Analysis ──── depends on: ──── V1    │
  ├── AI Features ──── depends on: ──── V1       │
  ├── Squad Goals ──── depends on: ──── V1       │
  └── Community ──── depends on: ──── V1         │
                                                  │
V3 ──────────────────────────────────────────────┤
  ├── Venue Partner ──── depends on: ──── V1, V2 │
  ├── Marketplace ──── depends on: ──── V3 Venue │
  ├── Advanced Admin ──── depends on: ──── V1    │
  └── Coach Jobs ──── depends on: ──── V1        │
                                                  │
Future ──────────────────────────────────────────┘
  └── Scale ──── depends on: ──── All above
```

## Team & Resource Requirements

### MVP Team (Months 1-3)

| Role | Count | Notes |
|------|-------|-------|
| Flutter Developer | 2 | Full-stack (Flutter + Firebase) |
| UI/UX Designer | 1 | Part-time, design system already built |
| Product Manager | 1 | Also handles user research |
| QA Engineer | 1 | Manual + automated (Flutter Driver) |

### V1 Team (Months 4-8)

| Role | Count | Notes |
|------|-------|-------|
| Flutter Developer | 3 | +1 for payments + contracts |
| Backend Developer (Node/Cloud Functions) | 1 | Payment webhooks, notifications |
| UI/UX Designer | 1 | Full-time |
| Product Manager | 1 | — |
| QA Engineer | 1 | — |
| Customer Support | 1 | Coach/academy onboarding |

### V2 Team (Months 9-14)

| Role | Count | Notes |
|------|-------|-------|
| Flutter Developer | 4 | — |
| ML Engineer | 2 | Video analysis, AI features |
| Backend Developer | 2 | Cloud Functions, gamification engine |
| UI/UX Designer | 1 | — |
| Product Manager | 1 | — |
| QA Engineer | 2 | +1 for ML pipeline testing |
| Customer Support | 2 | — |
| Data Analyst | 1 | Gamification balance, user behavior |

### V3 Team (Months 15-20)

| Role | Count | Notes |
|------|-------|-------|
| Flutter Developer | 5 | — |
| ML Engineer | 2 | — |
| Backend Developer | 3 | — |
| UI/UX Designer | 1 | — |
| Product Manager | 1 | — |
| QA Engineer | 2 | — |
| Customer Support | 3 | Venue partner onboarding |
| Data Analyst | 1 | — |
| DevOps Engineer | 1 | — |
| Legal/Compliance | 1 | Payments, contracts, tax |

---

## Go-To-Market Timeline

### Pre-MVP (Month 1)

| Activity | Owner |
|----------|-------|
| Recruit 20 pilot coaches (Pune) | PM |
| Recruit 50 pilot players (Pune) | PM |
| Set up WhatsApp/Slack community | Community Lead |
| Create content: 10 "why SportsEco" posts | Content Writer |

### MVP Launch (Month 3)

| Activity | Owner |
|----------|-------|
| App Store + Play Store release | Dev |
| Press release (Pune local media) | Marketing |
| First 100 users onboarding calls | PM + Support |
| Daily standups with top 5 coaches | PM |

### V1 Launch (Month 8)

| Activity | Owner |
|----------|-------|
| Academy partnership drive (20 academies) | Partnerships |
| School outreach program | Marketing |
| Parent referral program | Growth |
| Coach onboarding campaign (100 coaches) | Marketing |
| Pune sports events sponsorship | Marketing |

### V2 Launch (Month 14)

| Activity | Owner |
|----------|-------|
| Gamification announcement campaign | Marketing |
| Video analysis demo days (coach workshops) | Product |
| AI feature beta program (100 users) | Product |
| Leaderboard contests (season 1) | Community |
| Press: "India's first AI-powered sports platform" | PR |

### V3 Launch (Month 20)

| Activity | Owner |
|----------|-------|
| Venue partner drive (50 venues) | Partnerships |
| Marketplace launch event (Pune) | Marketing |
| Coach subscription plans go live | Product |
| "Earn on SportsEco" campaign | Growth |
| City-by-city rollout plan activated | Operations |

---

## Feature Decommissioning & Sunset Policy

| Condition | Action |
|-----------|--------|
| Feature <5% MAU usage for 3 months | Review → deprecation notice → remove in next phase |
| Feature causes >10% of support tickets | Redesign or remove |
| Third-party API cost > revenue generated | Re-evaluate or build in-house |
| Security vulnerability in feature | Immediate freeze + fix or remove |
| Duplicate feature exists | Merge or remove older |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-04 | SportsEco Product Team | Initial roadmap |
