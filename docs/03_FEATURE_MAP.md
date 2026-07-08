# Feature Map: Complete Feature Inventory

Features are grouped into domains. Each feature includes: current status (exists/missing/partial), target role, and priority.

---

## 1. Authentication & User Management

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Email/Password Sign Up | Exists | All | P0 | 3-step signup (role -> personal -> credentials) |
| Email/Password Login | Exists | All | P0 | - |
| Google Sign-In | Exists | All | P0 | Using GoogleAuthProvider |
| Password Reset | Exists | All | P0 | Forgot password flow |
| Role Selection during Signup | Exists | All | P0 | Player, Coach, Academy, Parent, Admin |
| Phone Authentication | Missing | All | P1 | Needed for India market (OTP login) |
| Session Persistence | Exists | All | P0 | Firebase Auth state persistence |
| Profile Photo Upload | Exists | All | P0 | Firebase Storage integration |
| Profile Edit | Exists | All | P0 | Name, phone, city, bio |
| Account Deletion | Missing | All | P2 | GDPR compliance needed |
| Multi-account Switching | Missing | Parent | P2 | Parent managing multiple children |

## 2. Onboarding & First Launch

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Splash Screen | Exists | All | P0 | Animated splash with branding |
| Role Selection Screen | Exists | All | P0 | Step 1 of 3 in signup |
| Personal Info Step | Exists | All | P0 | Name, email, phone |
| Credentials Step | Exists | All | P0 | Password, Terms acceptance |
| Coach Profile Setup | Missing | Coach | P1 | Post-signup specialization, experience, rates |
| Academy Profile Setup | Missing | Academy | P1 | Post-signup sports, description, logo |
| Player Profile Setup | Missing | Player | P1 | Post-signup sports, age, level |
| Parent Child Linking | Missing | Parent | P1 | Add child player after signup |
| Tutorial/Tooltip Walkthrough | Missing | All | P2 | First-time user guidance |

## 3. Dashboards

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Player Dashboard | Exists | Player | P0 | KPIs, sessions, performance, coach carousel, achievements, community, timeline |
| Coach Dashboard | Exists | Coach | P0 | Stats, sessions, milestones, subscription, quick actions |
| Academy Dashboard | Exists | Academy | P0 | Stats, batches, advertising, placements |
| Parent Dashboard | Exists | Parent | P0 | Multi-player overview, quick stats, metric logging |
| Admin Dashboard | Exists | Admin | P0 | Users, venues, revenue, active users, tasks |
| Venue Partner Dashboard | Missing | Venue Partner | P1 | To be built |

## 4. Coaching & Sessions

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Create Session | Exists | Coach | P0 | Title, sport, description, datetime, capacity, venue, price, online flag |
| Book Session | Partial | Player | P0 | Requires booking flow refinement |
| Session Scheduling | Exists | Coach | P0 | Calendar-based view |
| Session Status (booked/scheduled/completed) | Exists | All | P0 | - |
| Cancel Session | Partial | Coach | P1 | UI exists, backend needs full implementation |
| Reschedule Session | Missing | Coach | P1 | - |
| Session Notifications | Missing | All | P1 | Calendar reminders, changes |
| Recurring Sessions | Missing | Coach | P2 | Weekly/monthly repeats |
| Session Notes/Feedback | Missing | Coach | P1 | Coach writes notes after session |
| Attendance Tracking | Missing | Coach | P1 | Mark player present/absent |
| Session Rating | Missing | Player | P1 | Rate coach after session |
| Session History | Exists | All | P0 | Past sessions list |

## 5. Coach Discovery

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Coach Listing | Exists | All | P0 | All coaches with basic info |
| Coach Search | Exists | All | P0 | By name, specialization, city (client-side filter) |
| Coach Profile View | Exists | All | P0 | Full profile with experience, rates, verification |
| Coach Rating & Reviews | Partial | All | P1 | Rating stored, reviews UI needed |
| Coach Verification Badge | Exists | All | P0 | isVerified flag shown in UI |
| Coach Specialization Filter | Partial | All | P1 | Needs server-side filter |
| Coach Location Filter | Partial | All | P1 | City-based only |
| Coach Hourly Rate Display | Exists | All | P0 | Shown in dashboard and listings |
| Coach Availability Calendar | Missing | Coach | P1 | Set available time slots |
| Coach Booking Request | Missing | Player | P1 | Request -> Approve flow |

## 6. Venues

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Venue Listings | Exists | All | P0 | Active venues with details |
| Venue Detail View | Exists | All | P0 | Full venue info, amenities, images |
| Venue Search | Partial | All | P0 | Client-side filter by name, sport, city |
| Venue Map Integration | Partial | All | P1 | Google Maps package included, UI needed |
| Venue Booking | Missing | All | P1 | Calendar-based slot booking |
| Venue Reviews | Missing | All | P1 | Post-visit ratings |
| Venue Photos | Exists | All | P0 | Image list in model |
| Venue Amenities | Exists | All | P0 | Parking, changing rooms, floodlights etc. |
| Venue Geolocation | Exists | All | P0 | Lat/lng in model |
| Add Venue (Admin) | Exists | Admin | P0 | Manual form-based addition |
| Venue Verification | Exists | Admin | P0 | isVerified flag |
| Google Places Integration | Partial | All | P2 | isGoogleSourced field exists |
| Dynamic Pricing | Missing | Venue | P2 | Peak/off-peak pricing |
| Venue Availability Calendar | Missing | Venue | P1 | Time slot management |

## 7. Academies

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Academy Profile | Exists | Academy | P0 | Name, logo, description, sports, social links |
| Batch Management | Exists | Academy | P0 | Create, edit, delete batches |
| Batch Capacity Tracking | Exists | Academy | P0 | enrolled/capacity tracking |
| Coach Assignment to Batch | Exists | Academy | P0 | Assign coaches to batches |
| Coach Invitation System | Exists | Academy | P0 | Send invitations to coaches |
| Academy Job Posting | Exists | Academy | P0 | Post coaching jobs |
| Job Applications | Exists | Academy | P0 | View and manage applications |
| Academy Placements | Exists | Academy | P0 | Track coach placements |
| Advertising Campaigns | Exists | Academy | P0 | Create campaigns (Product Ads, Social Boost, Community) |
| Campaign Budget Management | Exists | Academy | P0 | Budget field in campaigns |
| Student Enrollment | Missing | Academy | P1 | Direct student enrollment in batches |
| Academy Verification | Exists | Academy | P0 | isVerified flag |
| Academy Reputation System | Exists | Academy | P0 | reputationPoints field |
| Coach Performance Reports | Missing | Academy | P2 | Analytics on coach effectiveness |

## 8. Payments & Contracts

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Contract Creation | Exists | All | P0 | Draft contract with fee calculation |
| Contract Types (coaching, academy, subscription) | Exists | All | P0 | ContractType enum |
| Digital Signatures | Exists | All | P1 | Signature fields in model |
| Escrow System | Exists | All | P2 | isEscrowActive field |
| Platform Fee Calculation | Exists | All | P0 | 10% platform fee, 10% opportunity fee, 10% savings |
| Contract Status Workflow | Exists | All | P0 | draft -> pending -> active -> completed/cancelled/disputed |
| Contract List & Detail | Exists | All | P0 | User contracts filtered by party |
| Total Revenue Tracking | Exists | Admin | P0 | Stream-based revenue aggregation |
| Coach Earnings Dashboard | Exists | Coach | P0 | Monthly earnings, total earnings |
| Coach Subscription Tiers | Exists | Coach | P0 | Starter/Professional/Elite with pricing |
| In-App Payments | Missing | All | P1 | UPI, card, wallet integration |
| Payment History | Missing | All | P1 | Transaction log |
| Invoice Generation | Missing | All | P2 | Auto-generated invoices |
| Refund Processing | Missing | All | P2 | Via dispute system |

## 9. Messaging & Communication

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Chat List | Exists | All | P0 | Sorted by last message time |
| Chat Detail | Exists | All | P0 | Message list with sender info |
| Send Text Message | Exists | All | P0 | Real-time via Firestore |
| Send Image/File | Partial | All | P1 | MessageType enum supports image/file, UI pending |
| Create Chat | Exists | All | P0 | Between any two participants |
| Unread Count | Exists | All | P0 | Per-user unread tracking |
| Mark as Read | Exists | All | P0 | Resets unread count |
| Push Notifications | Missing | All | P1 | FCM configured, implementation pending |
| In-App Notifications | Missing | All | P1 | Notification center |
| Email Notifications | Missing | All | P2 | Transactional emails |

## 10. Community & Social

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Community Feed | Exists | All | P0 | Social feed with posts |
| Create Post | Exists | All | P0 | Text posts with media placeholders |
| Like Post | Partial | All | P1 | UI has likes, backend pending |
| Comment on Post | Partial | All | P1 | UI has comments, backend pending |
| Share Post | Partial | All | P2 | UI has share button |
| Image/Video in Post | Partial | All | P1 | Icons shown, upload pending |
| User Profiles in Feed | Exists | All | P0 | Shows user name, role, avatar |

## 11. Gamification

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Player Levels (1-6) | Exists | Player | P0 | Rookie -> Amateur -> Contender -> Champion -> Legend -> Mythic |
| Player Ranks (1-5) | Exists | Player | P0 | Bronze -> Silver -> Gold -> Platinum -> Diamond |
| Point System | Exists | Player | P0 | points field, FieldValue.increment |
| Achievement System | Exists | Player | P0 | 6 base achievements (First Win, On Fire, Champion, Team Up, Explorer, Social Butterfly) |
| Squad Goals | Exists | Player | P0 | Collaborative goals with rewards |
| Squad Goal Progress | Exists | Player | P0 | Progress bar, member contributions |
| Squad Goal Rewards | Exists | Player | P0 | Custom reward per goal |
| Daily Streak | Missing | Player | P1 | Consecutive login/session tracking |
| Weekly Missions | Missing | Player | P1 | Curated weekly challenges |
| Monthly Goals | Missing | Player | P1 | Monthly targets with bigger rewards |
| Coach Reputation Points | Exists | Coach | P0 | reputation system via ratings |
| Academy Reputation Points | Exists | Academy | P0 | reputationPoints field |
| Coach Career Milestones | Exists | Coach | P0 | Custom milestone tracking |
| Leaderboards | Missing | All | P1 | Sport-specific, city-specific rankings |
| Badge Display | Missing | All | P1 | Visual badge collection page |
| Season System | Missing | All | P2 | Competitive seasons with resets |

## 12. Video Analysis

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Video Upload | Exists | Player | P0 | From gallery, stored in Firebase Storage |
| Sport Selection for Analysis | Exists | Player | P0 | Dropdown: Cricket, Football, Tennis, etc. |
| AI Pose Score | Exists | Player | P0 | poseScore field, displayed as /100 |
| AI Feedback | Exists | Player | P0 | feedback field with coaching tips |
| Joint Angle Tracking | Partial | Player | P1 | jointAngles field exists, display pending |
| Processing Status | Exists | Player | P0 | processing -> completed/pending_review |
| Video History | Exists | Player | P0 | Chronological list with status and scores |
| Coach Review Flow | Exists | Player, Coach | P1 | Submit for coach review, coach provides feedback |
| Delete Video | Exists | Player | P0 | Storage + Firestore cleanup |
| Real-time Camera Capture | Missing | Player | P2 | Record directly in app |
| Batch Video Upload | Missing | Player | P2 | Multiple videos at once |
| Comparison View | Missing | Player | P2 | Side-by-side before/after |

## 13. Performance & Analytics

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Player Metric Logging | Exists | Parent, Player | P0 | Speed, duration, distance, accuracy |
| Player Metrics History | Exists | Player | P0 | playerMetrics collection |
| Performance Tab | Exists | Player | P0 | Visual performance overview |
| Coach Stats | Exists | Coach | P0 | Total sessions, students, earnings |
| Academy Stats | Exists | Academy | P0 | Students, coaches, reputation, placements |
| Monthly Earnings (Coach) | Exists | Coach | P0 | Current month breakdown |
| Active Users Count (Admin) | Exists | Admin | P0 | 30-day active users |
| Total Revenue (Admin) | Exists | Admin | P0 | Platform fees from completed contracts |
| Performance Charts | Missing | All | P1 | Visual trend lines and graphs |
| Player Comparison | Missing | Player | P2 | Compare with peers (anonymized) |
| Coach Effectiveness Score | Missing | Academy | P2 | Metric on coach impact |
| Attendance Analytics | Missing | Academy | P1 | Batch attendance trends |

## 14. Notifications

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Firebase Cloud Messaging | Exists | All | P0 | Package included, configured |
| Local Notifications | Exists | All | P0 | flutter_local_notifications configured |
| In-App Notification Bell | Partial | All | P1 | Icon in header, backend pending |
| Session Reminders | Missing | All | P1 | Push before scheduled session |
| Booking Confirmations | Missing | All | P1 | On successful booking |
| Message Notifications | Missing | All | P1 | On new chat message |
| Achievement Unlocked | Missing | Player | P2 | Celebrate milestone |
| Contract Updates | Missing | All | P1 | Status change notifications |

## 15. Admin & Operations

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| User Management | Exists | Admin | P0 | View all users |
| Venue Management | Exists | Admin | P0 | Add, verify venues |
| Coupon Management | Exists | Admin | P0 | Create, activate/deactivate |
| Admin Task Management | Exists | Admin | P0 | Create, prioritize, track tasks |
| Platform Revenue Dashboard | Exists | Admin | P0 | Total revenue stream |
| Active User Tracking | Exists | Admin | P0 | 30-day active users |
| Content Moderation | Missing | Admin | P2 | Report and review system |
| System Health Monitoring | Missing | Admin | P2 | Firebase function monitoring |

## 16. Design System & UX

| Feature | Status | Roles | Priority | Notes |
|---|---|---|---|---|
| Dark Theme | Exists | All | P0 | Full dark mode implementation |
| Light Theme | Exists | All | P0 | Full light mode implementation |
| Theme Toggle | Exists | All | P0 | Switch between light/dark |
| Responsive Layout | Exists | All | P0 | Desktop sidebar, tablet collapsed, mobile bottom nav |
| Custom Icons | Exists | All | P0 | AppIcons with sports-themed icons |
| Glassmorphism Cards | Exists | All | P1 | GlassCard widget |
| Shimmer Loading | Exists | All | P0 | ShimmerWidget for loading states |
| Empty States | Exists | All | P0 | EmptyState with icon, title, action |
| Error States | Exists | All | P0 | ErrorState with retry |
| Lottie Animations | Exists | All | P1 | Lottie integration for celebrations |
| Animated Transitions | Exists | All | P0 | flutter_animate for micro-interactions |
| Premium Nav Shell | Exists | All | P0 | Sidebar + TopBar on desktop, Drawer + BottomNav on mobile |
| Typography Scale | Exists | All | P0 | Complete text style system |
| Color System | Exists | All | P0 | Primary, secondary, accent, status, surface colors |
| Spacing Scale | Exists | All | P0 | Standardized spacing tokens |
| Radius System | Exists | All | P0 | Border radius tokens |
| Elevation System | Exists | All | P0 | Shadow and elevation tokens |
| Duration/Motion Tokens | Exists | All | P0 | Animation duration and curve tokens |

## Feature Domain Grouping (Architectural View)

```
AUTH & USERS
  Authentication, Profile, Roles, Onboarding

COACHING CORE
  Sessions, Coach Discovery, Coach Dashboard, Student Management

ACADEMY OPERATIONS
  Batches, Coach Hiring, Placements, Job Board, Campaigns

VENUE ECOSYSTEM
  Discovery, Detail, Booking, Reviews, Availability

FINANCIAL LAYER
  Contracts, Payments, Subscriptions, Earnings, Revenue

COMMUNICATION
  Chat, Notifications, Community Feed

PERFORMANCE LAYER
  Metrics, Video Analysis, Reports, Analytics

GAMIFICATION
  Levels, Ranks, XP, Achievements, Squad Goals, Milestones

ADMIN & PLATFORM
  User Admin, Venue Admin, Coupons, Tasks, Revenue

DESIGN FOUNDATION
  Theme, Responsive, Components, Motion, Tokens
```
