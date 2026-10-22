# IMPLEMENTATION_CONTEXT.md

> **Purpose:** Enable a senior Flutter developer to immediately begin implementing remaining features without re-analyzing the codebase.
> **Generated:** July 25, 2026
> **Project:** SportsEco (Sports Ecosystem Platform - Pune Pilot)
> **Codebase:** 131 Dart files | 8 models | 7 services | 55 providers | 56+ screen files | 76 design system files

---

## 1. CURRENT APPLICATION STATE

### What Works End-to-End

| Flow | Description |
|------|-------------|
| **Auth (Signup/Login/Logout)** | Email/password + Google sign-in, role selection, profile creation in Firestore, redirect to role shell |
| **Coach Discovery** | Player/Parent can browse all coaches from Firestore, filter client-side by sport/city/rating |
| **Session Booking (basic)** | Player can book a session via bottom sheet on coach card → writes to `sessions` collection |
| **Coach Session Creation** | Coach can create a session with title, sport, date/time, venue, price → writes to `sessions` |
| **Session Viewing** | Coach sees upcoming sessions in Schedule tab; player sees sessions in Performance tab |
| **Chat (basic)** | List + detail screens exist, messages read/write to Firestore subcollection, mark as read |
| **Contract Creation & Signing** | Draft contract with fee calculation (10% platform + 10% opportunity + 10% savings), both parties can sign digitally |
| **Contract List/Detail** | User can view their contracts and see signing status |
| **Player Metrics Logging** | Parent/player can log Speed, Duration, Distance, Accuracy → writes to `playerMetrics` |
| **Performance Charts** | Player sees line chart of metrics over time via fl_chart |
| **Achievement System** | Static catalog of 6 achievements checked against Firestore `playerAchievements` |
| **Gamification Display** | Level (Rookie→Mythic) and Rank (Bronze→Diamond) computed from `PlayerModel.points` |
| **Venue Listing** | Admin sees all venues, can add new venues to Firestore |
| **Coach Profile Display** | Coach dashboard shows stats, earnings, milestones, subscription info |
| **Academy Batch Management** | Academy can create, edit, and soft-delete batches |
| **Academy Coach Invitation** | Academy can invite coaches by email |
| **Academy Campaign Creation** | Academy can create advertising campaigns |
| **Job Posting & Application** | Academy posts jobs; coaches browse and apply |
| **Admin Stats Dashboard** | Total users, venues, revenue, active users counters |
| **Admin Coupon Management** | Create and toggle active/inactive coupons |
| **Admin Task List** | View admin tasks with status |
| **Theme Toggle** | Dark/Light mode persisted to SharedPreferences |
| **Responsive Shell** | PremiumShell handles phone/tablet/desktop layouts with sidebar/drawer/bottom-nav |

### What Only Has UI (No Backend Wiring)

| Feature | Screen(s) | What's Missing |
|---------|-----------|----------------|
| Community Likes/Comments/Shares | `community_screen.dart` | Buttons show "coming soon" SnackBar; no Firestore writes |
| Media Attachments | `community_screen.dart` | Image/video/emoji buttons show "coming soon" |
| Session Cancel/Reschedule | `coach_dashboard.dart` | Cancel shows SnackBar without Firestore update; reschedule is "coming soon" |
| Video Session Start | `coach_dashboard.dart` | "Start Video Session" is "coming soon" |
| Subscription Management | `coach_dashboard.dart` | Plan options display-only, no payment flow |
| Academy Job Quick Action | `coach_dashboard.dart` | Shows "coming soon" instead of navigating |
| Reports Quick Action | `coach_dashboard.dart` | Shows "coming soon" |
| Venue Booking | `venue_discovery_screen.dart` | Venue list only, no booking capability |
| Venue Detail | `venue_detail_screen.dart` | Displays venue info but no booking CTA |
| Venue Photo Upload | `admin_dashboard.dart` | "Add Photos" button has empty `onTap` |
| Ad Campaign Management | `advertising_tab.dart` | Can create but cannot edit/delete campaigns |
| Task Detail | `admin_dashboard.dart` | Task card `onTap` is empty |
| Batch Detail View | `batches_tab.dart` | "View" button shows SnackBar only |
| Student Detail View | `students_tab.dart` | Cards are display-only, no `onTap` |
| Session Detail View | `schedule_tab.dart` | Cards are display-only, no `onTap` |
| Coach Profile Detail | `academy_coaches_tab.dart` | No tap-to-view-profile |
| Application Withdrawal | `coach_academy_jobs_screen.dart` | Cannot withdraw once applied |
| Job Editing/Deletion | `academy_jobs_tab.dart` | Jobs are immutable after creation |

### What Has Backend But Incomplete UI

| Feature | Backend Exists | UI Gap |
|---------|---------------|--------|
| Chat messaging | Full CRUD in `ChatService` | No file/image attachments, no typing indicators, no read receipts display |
| Player metrics | `logMetric()` in `PlayerService` | Only 4 metric types (Speed, Duration, Distance, Accuracy); Performance tab shows 5 types (Speed, Stamina, Technique, Strength, Agility) - mismatch |
| Coach milestones | Full CRUD in `CoachService` | Works but no drag-to-reorder, no completion date display |
| Job applications | `applyForJob()` in `AcademyService` | Academy cannot view applicants; coach cannot withdraw |
| Coach invitations | Full flow in `AcademyService` | Coach cannot accept/decline from the UI |
| Batch enrollment | `assignStudentToBatch()` exists | Bug: `studentId` parameter is unused; no enrollment UI |

### What Is Completely Missing

| Feature | Status |
|---------|--------|
| **Payment Gateway Integration** | No Razorpay/Stripe/Paytm; fee model exists but no actual payment |
| **Push Notifications** | `firebase_messaging` declared but no service, no handlers, no token registration |
| **Availability Calendar** | No coach availability system; sessions have date/time but no availability slots |
| **Review/Rating System** | `CoachModel.rating`/`totalReviews` exist but no review creation UI or service |
| **Attendance Tracking** | No check-in/check-out for sessions |
| **Session History (Player)** | Player cannot see past completed sessions |
| **Parent→Child Linking** | No wizard to add/link a child to a parent account post-signup |
| **Onboarding Wizard** | No first-time user onboarding for any role |
| **Image/Video Upload (Community)** | No media attachment support |
| **Notification Center** | No in-app notification inbox |
| **Admin User Management** | Users list is read-only; no ban/edit/delete |
| **Admin Venue Verification** | Can add venues but not verify/edit/delete |
| **Venue Map Integration** | Google Maps declared but unused; no map view |
| **Search Backend** | Client-side filtering only; no Firestore text search or Algolia |
| **Offline Support** | No local caching beyond theme persistence |
| **Error Handling Layer** | No Result/Either wrapper; errors only surface via AsyncValue.when |
| **Analytics/Crash Reporting** | No Firebase Analytics or Crashlytics integration |
| **Tests** | Only default `widget_test.dart` exists |
| **CI/CD Pipeline** | No GitHub Actions or Codemagic |
| **Localization** | All strings hardcoded in English |

---

## 2. USER JOURNEYS / BUSINESS FLOWS

### PLAYER Journey

```
Signup → Profile Creation → Onboarding Wizard → Player Dashboard
    ↓
Browse Coaches → View Coach Details → Book Session → Payment → Contract
    ↓
Training Sessions → Log Performance Metrics → View Performance Charts
    ↓
Upload Video → AI Analysis / Coach Review → Get Feedback
    ↓
Join Squad Goals → Track Progress → Earn Points → Level Up → Unlock Achievements
    ↓
Community Posts → Like/Comment/Share → Social Engagement
    ↓
Chat with Coach/Academy
```

| Step | Current Implementation | Files | Missing Implementation | Required Changes |
|------|----------------------|-------|----------------------|-----------------|
| **Signup** | Email/password + Google, role selection | `signup_screen.dart`, `auth_service.dart` | Post-signup onboarding wizard | Create onboarding screen with sport preference, skill level, goals |
| **Profile Creation** | Basic info (name, email, phone) in signup | `signup_screen.dart`, `auth_service.dart` | Extended profile (bio, sports, avatar, age) | Add profile edit screen; update `PlayerModel` write in signUp |
| **Browse Coaches** | List all coaches with client-side filter | `coach_discovery_screen.dart`, `coach_service.dart` | Coach detail screen, pagination | Create `coach_detail_screen.dart`; add Firestore query filters |
| **View Coach Details** | No screen exists | -- | Full coach profile with reviews, sessions, availability | Create `coach_detail_screen.dart` with reviews section |
| **Book Session** | Bottom sheet with date/time on coach card | `coach_discovery_screen.dart` | Proper booking flow, slot selection | Create `booking_flow_screen.dart` with availability check |
| **Payment** | Fee model exists in `ContractService.draftContract()` | `contract_service.dart` | Razorpay/Stripe integration | Integrate payment SDK; create `payment_service.dart` |
| **Contract** | Draft + sign flow exists | `contract_list_screen.dart`, `contract_detail_screen.dart`, `contract_service.dart` | Auto-trigger after payment, escrow management | Wire payment → contract creation; add escrow service |
| **Training Sessions** | View upcoming sessions in Performance tab | `performance_tab.dart`, `coach_service.dart` | Session detail, past sessions, attendance | Add session detail screen; add attendance service |
| **Log Performance** | Log 4 metrics (Speed/Duration/Distance/Accuracy) | `parent_dashboard.dart`, `player_service.dart` | Expand metric types, coach-initiated logging | Add all metric types from `PerformanceTab` constants |
| **View Performance Charts** | Line chart with 5 metric types | `performance_tab.dart` | Historical comparison, coach annotations | Add comparison mode; add coach feedback overlay |
| **Upload Video** | Upload to Firebase Storage | `video_analysis_screen.dart`, `video_analysis_service.dart` | Real AI analysis (currently mock), coach review UI | Integrate ML Kit or external API; create review screen |
| **Squad Goals** | Create, contribute, complete | `squad_goals_screen.dart`, `squad_goals_service.dart` | Leaderboard, notifications on completion | Add leaderboard UI; add completion notifications |
| **Community** | Create posts, view feed | `community_screen.dart` | Like/comment/share, media attachments | Add interaction handlers; add media upload |
| **Chat** | List + detail screens, send/read messages | `chat_list_screen.dart`, `chat_detail_screen.dart`, `chat_service.dart` | File/image messages, typing indicators | Add attachment picker; add typing indicator service |

### COACH Journey

```
Signup → Profile Creation → Coach Dashboard
    ↓
View Stats → Manage Schedule → View Students → Track Earnings
    ↓
Create Sessions → View Bookings → Accept/Reject → Mark Attendance
    ↓
Manage Milestones → Career Progress
    ↓
Browse Academy Jobs → Apply → View Applications
    ↓
Respond to Academy Invitations → Join Academy
    ↓
Subscription Management → Upgrade Plan
    ↓
Community + Chat
```

| Step | Current Implementation | Files | Missing Implementation | Required Changes |
|------|----------------------|-------|----------------------|-----------------|
| **Dashboard** | Stats, sessions, milestones, subscription display | `coach_dashboard.dart` | Navigation to detail views; session actions | Add `onTap` handlers; wire session actions |
| **Manage Schedule** | View upcoming sessions | `schedule_tab.dart` | Calendar view, date filtering, session actions | Create calendar widget; add session CRUD actions |
| **View Students** | List of assigned players | `students_tab.dart` | Student detail view, messaging, metrics | Add `onTap` → student detail; add quick-message |
| **Track Earnings** | Monthly earnings computed from sessions × rate | `earnings_tab.dart` | Payout history, withdrawal, tax info | Create earnings detail/history screen |
| **Create Session** | Form with fields, writes to Firestore | `create_session_screen.dart` | Player selection, venue picker, recurrence | Add player picker; add venue autocomplete |
| **Accept/Reject Bookings** | Not implemented | -- | Accept/reject incoming booking requests | Add `acceptBooking()`/`rejectBooking()` to `CoachService`; create booking request list |
| **Mark Attendance** | Not implemented | -- | Check-in/check-out for sessions | Add `AttendanceService`; add attendance UI on session cards |
| **Academy Jobs** | Browse and apply for jobs | `coach_academy_jobs_screen.dart` | Withdraw application, view application status detail | Add withdraw method; add application detail view |
| **Invitations** | List received invitations | Via `coachInvitationsProvider` | Accept/decline invitations | Add accept/decline buttons to invitation cards |
| **Subscription** | Display plan and pricing | `coach_dashboard.dart` | Actual payment and upgrade flow | Integrate payment gateway; create `subscription_service.dart` |

### ACADEMY Journey

```
Signup → Academy Profile Creation → Academy Dashboard
    ↓
Manage Batches → Create/Edit/Delete → Assign Coaches → Enroll Students
    ↓
Recruit Coaches → Search → Invite → Track Invitations
    ↓
Post Jobs → View Applications → Hire Coach
    ↓
Create Campaigns → Track Performance
    ↓
View Placements → Track Reputation
    ↓
Chat + Profile
```

| Step | Current Implementation | Files | Missing Implementation | Required Changes |
|------|----------------------|-------|----------------------|-----------------|
| **Dashboard** | Stats, batches, placements, campaigns | `academy_dashboard.dart` | Navigate to detail views; analytics | Add navigation handlers; add analytics section |
| **Manage Batches** | CRUD for batches (create, edit, archive) | `batches_tab.dart`, `academy_service.dart` | Batch detail with enrolled students; student enrollment | Create `batch_detail_screen.dart`; fix `assignStudentToBatch()` |
| **Recruit Coaches** | Search all coaches, send invitation | `academy_coaches_tab.dart` | Coach profile preview; revoke invitation | Add coach detail popup; add revoke method |
| **Post Jobs** | Create job listing | `academy_jobs_tab.dart` | Edit/delete jobs; view applicants | Add edit/delete; add applicants view screen |
| **Create Campaigns** | Basic campaign creation | `advertising_tab.dart` | Campaign analytics; edit/delete | Add analytics; add CRUD |
| **Placements** | View recent placements | `academy_dashboard.dart` | Full placement history | Add placement history screen |

### PARENT Journey

```
Signup → Add/Link Children → Parent Dashboard
    ↓
View Children Stats → Track Progress → Log Metrics
    ↓
Find Coach → Book Session for Child → Payment → Contract
    ↓
View Reports → Performance Charts
    ↓
Chat with Coach
```

| Step | Current Implementation | Files | Missing Implementation | Required Changes |
|------|----------------------|-------|----------------------|-----------------|
| **Dashboard** | Stats from linked players, quick actions | `parent_dashboard.dart` | Child linking wizard; add child flow | Create `add_child_screen.dart`; create child linking service |
| **Find Coach** | Browse coaches | `coach_discovery_screen.dart` | Book on behalf of child | Modify booking flow to select child |
| **Track Progress** | Per-child progress cards | `parent_progress_screen.dart` | Detailed per-child reports; comparison | Create detailed child report screen |
| **Log Metrics** | Quick metrics entry form | `parent_dashboard.dart` | More metric types; coach-initiated logging | Expand metric options |

### ADMIN Journey

```
Login → Admin Dashboard
    ↓
View Platform Stats → Users → Venues → Coupons → Tasks
    ↓
Manage Users → View/Ban/Verify
    ↓
Manage Venues → Add/Edit/Verify/Remove
    ↓
Manage Coupons → Create/Edit/Delete
    ↓
Manage Tasks → Create/Complete
    ↓
Revenue Reports → Transaction History
```

| Step | Current Implementation | Files | Missing Implementation | Required Changes |
|------|----------------------|-------|----------------------|-----------------|
| **Dashboard** | Stats counters, task list, venue form, coupons | `admin_dashboard.dart` | Deep analytics, charts | Create analytics dashboard with fl_chart |
| **Manage Users** | Read-only user list | `users_tab.dart` | Ban/edit/delete/verify users | Add user actions; add user detail screen |
| **Manage Venues** | Add venue only | `admin_dashboard.dart` | Edit/delete/verify venues | Add venue management screen |
| **Manage Coupons** | Create and toggle active/inactive | `coupons_tab.dart` | Edit/delete/expiry/usage stats | Add edit/delete; add expiry field |
| **Revenue** | Total revenue counter | `admin_dashboard.dart` | Transaction list, charts | Create revenue detail screen |

---

## 3. COMPLETE FEATURE IMPLEMENTATION STATUS

### Authentication

| Aspect | Status |
|--------|--------|
| **Current UI** | `splash_screen.dart`, `login_screen.dart`, `signup_screen.dart`, `forgot_password_screen.dart` |
| **Current Backend** | `AuthService`: signIn, signUp (email+password), signInWithGoogle, signOut, sendPasswordResetEmail, getUserProfile, updateProfile, uploadProfilePhoto, updatePassword |
| **Current Database** | `users` collection: uid, email, name, phone, role, photoUrl, city, bio, createdAt, updatedAt, isActive. Also writes to role-specific collections (`coaches`, `academies`, `players`) during signup |
| **Missing Pieces** | Phone/OTP auth, onboarding wizard post-signup, extended profile editing screen, profile photo upload UI, email verification |
| **Priority** | P1 |

### Coach Discovery

| Aspect | Status |
|--------|--------|
| **Current UI** | `coach_discovery_screen.dart`: list with search, sport/city/rating filter chips, book now button |
| **Current Backend** | `CoachService`: getCoaches (stream), searchCoaches (client-side), bookSession |
| **Current Database** | `coaches` collection: 20+ fields including name, specialization, hourlyRate, rating, isVerified, academyId |
| **Missing Pieces** | Coach detail screen (full profile, reviews, availability, sessions), server-side search/pagination, favorites/bookmarks, availability calendar |
| **Priority** | P1 |

### Session Management

| Aspect | Status |
|--------|--------|
| **Current UI** | `create_session_screen.dart` (coach), `schedule_tab.dart` (coach), session cards in `coach_dashboard.dart` and `performance_tab.dart` |
| **Current Backend** | `CoachService`: createSession, bookSession, getCoachSessions, getPlayerSessions, getCoachStats |
| **Current Database** | `sessions` collection: coachId, playerId, title, sport, dateTime, status, capacity, venue, price, isOnline |
| **Missing Pieces** | Session detail screen, accept/reject flow, attendance tracking, session history, calendar view, rescheduling, cancellation (backend) |
| **Priority** | P1 |

### Booking System
    
| Aspect | Status |
|--------|--------|
| **Current UI** | Bottom sheet on coach card in `coach_discovery_screen.dart` with date/time/sport pickers |
| **Current Backend** | `CoachService.bookSession()` creates a session document with status `'booked'` |
| **Current Database** | `sessions` collection (same as session management) |
| **Missing Pieces** | Full booking flow screen, availability check, booking confirmation, booking history, cancellation, slot management, child selection for parents |
| **Priority** | P1 |

### Contracts

| Aspect | Status |
|--------|--------|
| **Current UI** | `contract_list_screen.dart`, `contract_detail_screen.dart`: list with filtering, detail with sign/decline actions |
| **Current Backend** | `ContractService`: createContract, getContract, getUserContracts, signContract, updateStatus, getTotalRevenueStream, draftContract (static) |
| **Current Database** | `contracts` collection: type, partyA/B, amount, fees, status, signatures, dates, terms |
| **Missing Pieces** | Auto-creation after payment, escrow management, contract PDF generation, dispute flow, contract renewal |
| **Priority** | P1 (partially complete) |

### Payments

| Aspect | Status |
|--------|--------|
| **Current UI** | Subscription pricing display in `coach_dashboard.dart` (hardcoded: Starter=0, Professional=499, Premium=999) |
| **Current Backend** | Fee calculation in `ContractService.draftContract()`: platformFee (10%), opportunityFee (10%), contractSavings (10%) |
| **Current Database** | Fee fields stored on `contracts` collection |
| **Missing Pieces** | Payment gateway integration (Razorpay recommended for India), payment records collection, refund handling, invoice generation, subscription billing |
| **Priority** | P0 (blocks core marketplace) |

### Chat

| Aspect | Status |
|--------|--------|
| **Current UI** | `chat_list_screen.dart`, `chat_detail_screen.dart`: list sorted by last message, message bubbles, send text |
| **Current Backend** | `ChatService`: getUserChats, getChatMessages, sendMessage, createChat, markAsRead |
| **Current Database** | `chats` collection with `messages` subcollection: participants, lastMessage, unreadCount, message text/type/media |
| **Missing Pieces** | Image/file attachments, typing indicators, online status, message reactions, delete/edit messages, push notifications on new message, chat search |
| **Priority** | P2 |

### Community

| Aspect | Status |
|--------|--------|
| **Current UI** | `community_screen.dart`: post composer, post cards with author, content, like/comment/share buttons |
| **Current Backend** | Inline provider querying `posts` collection; direct Firestore writes for new posts |
| **Current Database** | `posts` collection: content, authorId, authorName, authorRole, likes, comments, createdAt |
| **Missing Pieces** | Like/comment/share backend, media attachments, post reports, user profiles on tap, hashtag/topic system, trending posts |
| **Priority** | P2 |

### Video Analysis

| Aspect | Status |
|--------|--------|
| **Current UI** | `video_analysis_screen.dart`: upload video, view analysis results with score/feedback |
| **Current Backend** | `VideoAnalysisService`: uploadVideo, getPlayerVideos, getLatestVideo, submitForCoachReview, provideCoachFeedback, deleteVideo |
| **Current Database** | `videoAnalysis` collection: videoUrl, poseScore, jointAngles, feedback, status, coachId |
| **Missing Pieces** | Actual AI analysis (currently mock/placeholder), ML Kit integration, video player, coach review queue, progress tracking over time |
| **Priority** | P3 |

### Squad Goals

| Aspect | Status |
|--------|--------|
| **Current UI** | `squad_goals_screen.dart`: active goals list, create goal, contribute to goal |
| **Current Backend** | `SquadGoalsService`: getActiveGoalsBySport, getPlayerGoals, createGoal, contribute (transaction), completeGoal |
| **Current Database** | `squadGoals` collection: title, targetValue, currentValue, memberIds, memberContributions, status |
| **Missing Pieces** | Notifications on goal completion, leaderboard, goal history, team chat, reward redemption |
| **Priority** | P3 |

### Performance Tracking

| Aspect | Status |
|--------|--------|
| **Current UI** | `performance_tab.dart`: line chart, metric type selector, recent sessions list, log session |
| **Current Backend** | `PlayerService`: logMetric, getPlayerMetrics, addPoints |
| **Current Database** | `playerMetrics` collection: metric, value, unit, loggedAt |
| **Missing Pieces** | Expanded metric types (Stamina/Technique/Strength/Agility not matching log form), coach annotations, comparison views, PDF reports, goals vs actuals |
| **Priority** | P2 |

### Gamification

| Aspect | Status |
|--------|--------|
| **Current UI** | `achievement_tab.dart`: level/rank display, achievement cards with lock/unlock |
| **Current Backend** | Static `LevelModel` (6 levels), `RankModel` (5 ranks), `AchievementModel` (6 achievements); `PlayerService.addPoints()` |
| **Current Database** | `playerAchievements` collection: playerId, achievementId, unlockedAt |
| **Missing Pieces** | Automatic achievement unlocking on events, point earning rules engine, daily/weekly challenges, streaks, leaderboard |
| **Priority** | P3 |

### Venue Discovery

| Aspect | Status |
|--------|--------|
| **Current UI** | `venue_discovery_screen.dart`: venue cards list; `venue_detail_screen.dart`: venue info display |
| **Current Backend** | `VenueService`: getVenues, getVenue, addVenue, updateVenue, searchVenues |
| **Current Database** | `venues` collection: name, address, lat/lng, amenities, images, sports, rating, pricePerHour |
| **Missing Pieces** | Map integration (Google Maps), booking flow, venue reviews, photo gallery, distance calculation, availability calendar |
| **Priority** | P2 |

### Academy Management

| Aspect | Status |
|--------|--------|
| **Current UI** | `academy_dashboard.dart` (stats, batches, campaigns, placements), `batches_tab.dart` (CRUD), `academy_coaches_tab.dart` (invite), `advertising_tab.dart` (campaigns), `academy_jobs_tab.dart` (jobs) |
| **Current Backend** | `AcademyService`: 23 methods covering batches, coaches, placements, campaigns, invitations, jobs |
| **Current Database** | `academies`, `batches`, `academyPlacements`, `coachInvitations`, `campaigns`, `coachJobs`, `jobApplications` |
| **Missing Pieces** | Student enrollment, batch detail, placement history, campaign analytics, academy analytics, reputation management |
| **Priority** | P2 |

### Job Portal

| Aspect | Status |
|--------|--------|
| **Current UI** | `academy_jobs_tab.dart` (post jobs), `coach_academy_jobs_screen.dart` (browse + apply) |
| **Current Backend** | `AcademyService`: postJob, getJobs, getAcademyJobs, applyForJob, getJobApplications |
| **Current Database** | `coachJobs` collection, `jobApplications` collection |
| **Missing Pieces** | Edit/delete jobs, view applicants (academy), withdraw application (coach), job search/filter, saved jobs, application status updates |
| **Priority** | P2 |

### Notifications

| Aspect | Status |
|--------|--------|
| **Current UI** | None (notification bell in PremiumTopBar has no badge count wiring) |
| **Current Backend** | `firebase_messaging: ^16.0.4` and `flutter_local_notifications: ^22.0.0` declared in pubspec but unused |
| **Current Database** | `notifications` collection exists in Firestore rules but no service writes to it |
| **Missing Pieces** | Complete push notification service, token registration, foreground handler, background handler, notification center screen, in-app notification list, read/unread state |
| **Priority** | P1 (critical for engagement) |

### Admin Management

| Aspect | Status |
|--------|--------|
| **Current UI** | `admin_dashboard.dart` (stats, tasks, venue form, coupons), `users_tab.dart` (user list), `coupons_tab.dart` (coupon CRUD) |
| **Current Backend** | `AuthService`: getUsers, getCoupons, addCoupon, toggleCouponStatus, getAdminTasks, addAdminTask, getActiveUsersCount |
| **Current Database** | `users`, `coupons`, `adminTasks` collections |
| **Missing Pieces** | User ban/edit/delete/verify, venue edit/delete/verify, task management (complete/reassign), deep analytics, revenue breakdown, growth charts |
| **Priority** | P2 |

---

## 4. FIREBASE DATABASE ANALYSIS

### Firestore Collections

| Collection | Purpose | Current Fields | Used By | Missing Fields for Future |
|-----------|---------|---------------|---------|--------------------------|
| `users` | User accounts (all roles) | uid, email, name, phone, role, photoUrl, city, bio, createdAt, updatedAt, isActive, lastLoginAt | AuthService | fcmToken, onboardingComplete, preferences, language |
| `coaches` | Coach profiles | coachId, name, email, phone, photoUrl, city, specialization, experience, hourlyRate, bio, rating, totalReviews, subscriptionTier, isSubscribed, subscriptionExpiry, certificates, workExperience, isVerified, academyId, createdAt, updatedAt | AuthService, CoachService, AcademyService | availability (map of day→slots), specialties, latitude, longitude, portfolioUrls |
| `academies` | Academy profiles | academyId, name, email, phone, logoUrl, description, address, city, sports, website, socialLinks, reputationPoints, coachPlacements, totalStudents, isVerified, createdAt, updatedAt | AuthService, AcademyService | latitude, longitude, gallery, foundedYear, totalRevenue |
| `players` | Player profiles | playerId, parentId, name, age, sports, level, rank, points, championshipWins, tournamentPoints, avatarUrl, coachId, academyId, createdAt, updatedAt | AuthService, PlayerService | height, weight, medicalNotes, emergencyContact, onboardingComplete |
| `venues` | Venue listings | venueId, name, description, address, city, latitude, longitude, amenities, images, contactPhone, website, openingHours, sports, capacity, rating, isGoogleSourced, googlePlaceId, isActive, addedBy, isVerified, pricePerHour, createdAt, updatedAt | VenueService, Admin | totalBookings, operatingHours (structured), slots |
| `sessions` | Training sessions | coachId, playerId, title, sport, dateTime, status, capacity, venue, price, isOnline, description | CoachService | recurringId, attendees[], attendance[], notes, rating, feedback |
| `contracts` | Digital contracts | contractId, type, partyAId, partyBId, partyARole, partyBRole, amount, platformFee, opportunityFee, contractSavings, totalAmount, status, startDate, endDate, terms, signatures, dates, isEscrowActive, escrowReleaseDate, createdAt, updatedAt | ContractService | paymentId, milestones[], renewalTerms |
| `chats/{id}/messages` | Chat messages | participants, lastMessage, lastMessageTime, lastMessageSender, unreadCount, isActive; Messages: messageId, senderId, text, messageType, mediaUrl, isRead, isDelivered | ChatService | typing status, reactions, replyTo, deliveredAt, readAt |
| `batches` | Academy training batches | academyId, name, sport, capacity, schedule, coachId, enrolled, isActive, deletedAt | AcademyService | studentIds[], sessionId[], waitlist[] |
| `coachMilestones` | Coach career milestones | coachId, label, done, createdAt, completedAt | CoachService | (complete) |
| `playerMetrics` | Player performance logs | playerId, metric, value, unit, loggedAt | PlayerService | sessionId, notes, coachId (who logged it) |
| `academyPlacements` | Coach placements at academies | academyId, coachId, batchId, placedAt | AcademyService | status, endDate |
| `coachInvitations` | Academy→Coach invitations | academyId, academyName, coachId, coachEmail, coachName, status, createdAt, updatedAt | AcademyService | expiresAt, message |
| `campaigns` | Academy advertising campaigns | academyId, name, budget, type, status, createdAt | AcademyService | impressions, clicks, conversions, endDate, targetAudience |
| `coachJobs` | Job postings | academyId, title, sport, location, salary, experience, description, perks, status, createdAt | AcademyService | applicantsCount, expiresAt, remote |
| `jobApplications` | Coach job applications | jobId, coachId, coachName, coachEmail, status, createdAt | AcademyService | coverLetter, resumeUrl, interviewDate |
| `videoAnalysis` | Video analysis results | videoId, playerId, sport, videoUrl, poseScore, jointAngles, feedback, status, uploadedAt, coachId, reviewedAt | VideoAnalysisService | modelVersion, processingTime |
| `squadGoals` | Team goal tracking | goalId, title, description, sport, targetValue, currentValue, metric, metricUnit, memberIds, memberContributions, creatorId, reward, status, deadline, createdAt, completedAt | SquadGoalsService | (complete for now) |
| `playerAchievements` | Unlocked achievements | playerId, achievementId, unlockedAt | Inline provider | (complete for now) |
| `posts` | Community posts | content, authorId, authorName, authorRole, likes, comments[], createdAt | Inline provider | mediaUrls, hashtags, shares, reports |
| `coupons` | Discount coupons | code, discount, eligibility, isActive, status, createdAt | AuthService | expiresAt, maxUses, usedCount, minAmount |
| `adminTasks` | Admin task tracker | title, status, priority, createdAt | AuthService | assigneeId, dueDate, description, completedAt |
| `notifications` | User notifications (collection exists in rules) | (no service writes to this) | None | userId, title, body, type, read, data, createdAt |

### Required Database Changes for Future Features

**For Booking:**
- Add `slots` field to `coaches` collection (availability per day of week)
- Add `bookingStatus` enum to `sessions` (requested, approved, rejected, cancelled)
- Add `requestedBy` field to `sessions`

**For Payment:**
- Create `payments` collection: paymentId, userId, contractId, amount, currency, method, status, gatewayResponse, createdAt
- Add `paymentId` field to `contracts`

**For Notifications:**
- Add `fcmToken` to `users` collection
- Write to `notifications` collection from all business events
- Add Firestore trigger for push notifications

**For Reviews:**
- Create `reviews` collection: reviewId, reviewerId, targetId (coach/venue), targetType, rating, comment, sessionId, createdAt
- Add `averageRating` and `reviewCount` computed fields to coaches/venues (or compute on read)

**For Attendance:**
- Add `attendance` map/array to `sessions`: {playerId: {checkedIn, checkedOut, status}}

**For Availability Calendar:**
- Create `availability` collection: coachId, dayOfWeek, slots[{start, end, isActive}], exceptions[{date, available}]

**For User Relationships:**
- Create `relationships` collection or add `linkedPlayerIds` to users for parent→child linking post-signup

---

## 5. SERVICE LAYER ANALYSIS

### AuthService (`lib/services/auth_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `authStateChanges()` | Stream of Firebase Auth state |
| `currentUser` | Current Firebase User |
| `signIn(email, password)` | Email/password login |
| `signInWithGoogle()` | Google OAuth login |
| `signUp(name, email, phone, password, role, city?)` | Create user + role profile |
| `signOut()` | Sign out |
| `sendPasswordResetEmail(email)` | Password reset |
| `getUserProfile(uid)` | Get UserModel from Firestore |
| `updateProfile(uid, data)` | Update user document |
| `uploadProfilePhoto(uid, filePath)` | Upload photo to Storage |
| `getUsers()` | Stream of all users |
| `updatePassword(current, new)` | Change password |
| `getCoupons()` | Stream of coupons |
| `addCoupon(code, discount, eligibility)` | Create coupon |
| `toggleCouponStatus(id, active)` | Toggle coupon active |
| `getAdminTasks()` | Stream of admin tasks |
| `addAdminTask(title, status, priority)` | Create task |
| `getActiveUsersCount()` | Count active users |
| `activeUsersStream()` | Stream of active count |

**Missing Methods Needed:**
- `deleteUser(uid)` — admin user deletion
- `banUser(uid, isBanned)` — admin user banning
- `verifyUser(uid)` — admin user verification
- `updateUserRole(uid, role)` — admin role change
- `linkChildAccount(parentId, childId)` — parent-child linking
- `searchUsers(query)` — admin user search
- `getUserStats()` — platform-wide user stats

### CoachService (`lib/services/coach_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `getCoaches()` | Stream of all coaches |
| `getCoach(coachId)` | Stream of single coach |
| `updateCoach(coachId, data)` | Update coach document |
| `searchCoaches(query)` | Client-side search |
| `getAcademyCoaches(academyId)` | Stream of academy's coaches |
| `bookSession(coachId, playerId, dateTime, sport)` | Create session booking |
| `createSession(coachId, title, sport, desc?, dateTime, capacity, venue, price, isOnline, playerId?)` | Create detailed session |
| `getCoachSessions(coachId)` | Stream of coach's sessions |
| `getPlayerSessions(playerId)` | Stream of player's sessions |
| `getCoachStats(coachId)` | Compute stats |
| `getCoachMilestones(coachId)` | Future of milestones |
| `addMilestone(coachId, label)` | Create milestone |
| `completeMilestone(milestoneId)` | Mark done |
| `deleteMilestone(milestoneId)` | Remove milestone |
| `getCoachMonthlyEarnings(coachId)` | Monthly earnings |
| `getCoachMilestonesStream(coachId)` | Stream of milestones |

**Missing Methods Needed:**
- `acceptBooking(sessionId)` — approve booking request
- `rejectBooking(sessionId, reason?)` — reject booking
- `cancelSession(sessionId)` — cancel session
- `rescheduleSession(sessionId, newDateTime)` — reschedule
- `completeSession(sessionId)` — mark completed
- `updateAvailability(coachId, availability)` — set schedule
- `getAvailability(coachId)` — get availability
- `getSessionHistory(coachId, {limit})` — past sessions
- `getCoachReviews(coachId)` — reviews list
- `respondToInvitation(invitationId, accept)` — accept/decline academy invite

### PlayerService (`lib/services/player_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `getParentPlayers(parentId)` | Stream of parent's players |
| `getPlayer(playerId)` | Stream of single player |
| `addPlayer(player)` | Write player document |
| `updatePlayer(playerId, data)` | Update player document |
| `logMetric(playerId, metric, value, unit)` | Log performance metric |
| `addPoints(playerId, points)` | Increment points atomically |
| `getPlayerMetrics(playerId)` | Stream of metrics |
| `getCoachPlayers(coachId)` | Stream of coach's players |

**Missing Methods Needed:**
- `searchPlayers(query)` — search players
- `getPlayersByAcademy(academyId)` — academy's players
- `enrollPlayerBatch(playerId, batchId)` — enroll in batch
- `getUnreadNotificationsCount(userId)` — notification badge count
- `getPlayerAchievements(playerId)` — achievements (currently inline in providers.dart)
- `unlockAchievement(playerId, achievementId)` — unlock achievement

### AcademyService (`lib/services/academy_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `getAcademy(academyId)` | Stream of academy |
| `updateAcademy(academyId, data)` | Update academy |
| `createBatch(academyId, name, sport, capacity, schedule)` | Create batch |
| `updateBatch(batchId, data)` | Update batch |
| `deleteBatch(batchId)` | Soft-delete batch |
| `getBatches(academyId)` | Stream of batches |
| `getPlacements(academyId)` | Stream of placements |
| `placeCoach(academyId, coachId, batchId)` | Record placement |
| `getActiveCoachesCount(academyId)` | Count coaches |
| `getCampaigns(academyId)` | Stream of campaigns |
| `createCampaign(academyId, name, budget, type)` | Create campaign |
| `inviteCoach(academyId, email)` | Send invitation |
| `sendCoachInvitation(academyId, academyName, coachId, coachEmail, coachName)` | Detailed invite |
| `updateInvitationStatus(invitationId, status)` | Update invite status |
| `getAcademyInvitations(academyId)` | Stream of sent invites |
| `getCoachInvitations(coachId)` | Stream of received invites |
| `assignCoachToBatch(batchId, coachId)` | Assign coach |
| `assignStudentToBatch(batchId, studentId)` | **BUG: studentId unused** |
| `postJob(academyId, title, sport, location, salary, experience, description, perks)` | Create job |
| `getJobs()` | Stream of all jobs |
| `getAcademyJobs(academyId)` | Stream of academy's jobs |
| `applyForJob(jobId, coachId, coachName, coachEmail)` | Apply |
| `getJobApplications(jobId)` | Stream of applications |

**Missing Methods Needed:**
- `getBatchStudents(batchId)` — list enrolled students
- `removeStudentFromBatch(batchId, studentId)` — unenroll
- `deleteCampaign(campaignId)` — remove campaign
- `deleteJob(jobId)` — remove job posting
- `updateJob(jobId, data)` — edit job
- `getPlacementHistory(academyId)` — all placements
- `updateApplicationStatus(applicationId, status)` — review application

### ChatService (`lib/services/chat_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `getUserChats(userId)` | Stream of user's chats |
| `getChatMessages(chatId)` | Stream of messages |
| `sendMessage(chatId, senderId, text, mediaUrl?, type)` | Send message |
| `createChat(participants)` | Create chat |
| `markAsRead(chatId, userId)` | Mark read |

**Missing Methods Needed:**
- `uploadMedia(chatId, senderId, filePath, type)` — upload image/file
- `deleteMessage(chatId, messageId)` — delete message
- `editMessage(chatId, messageId, newText)` — edit message
- `getOrCreateChat(userId1, userId2)` — find existing or create new
- `setTyping(chatId, userId, isTyping)` — typing indicator
- `searchMessages(chatId, query)` — search within chat

### VenueService (`lib/services/venue_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `getVenues()` | Stream of active venues |
| `getVenue(venueId)` | Stream of single venue |
| `addVenue(venue)` | Create venue |
| `updateVenue(venueId, data)` | Update venue |
| `searchVenues(query)` | Client-side search |

**Missing Methods Needed:**
- `deleteVenue(venueId)` — remove venue
- `verifyVenue(venueId, isVerified)` — admin verify
- `getVenuesBySport(sport)` — filter by sport
- `getNearbyVenues(lat, lng, radius)` — proximity search
- `addReview(venueId, userId, rating, comment)` — venue review
- `getReviews(venueId)` — venue reviews
- `bookVenue(venueId, userId, dateTime, duration)` — venue booking
- `getVenueBookings(venueId, date)` — availability check

### VideoAnalysisService (`lib/features/video_analysis/data/video_analysis_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `getPlayerVideos(playerId)` | Stream of player's videos |
| `getLatestVideo(playerId)` | Stream of latest video |
| `uploadVideo(playerId, sport, filePath)` | Upload to Storage |
| `submitForCoachReview(videoId, coachId)` | Assign to coach |
| `provideCoachFeedback(videoId, poseScore, feedback, jointAngles?)` | Write feedback |
| `deleteVideo(videoId, playerId)` | Delete (playerId unused) |

**Missing Methods Needed:**
- `getVideosPendingReview(coachId)` — coach review queue
- `updateAnalysisStatus(videoId, status)` — processing status

### SquadGoalsService (`lib/features/squad_goals/data/squad_goals_service.dart`)

| Existing Methods | Purpose |
|-----------------|---------|
| `getActiveGoalsBySport(sport)` | Stream of active goals by sport |
| `getPlayerGoals(playerId)` | Stream of player's goals |
| `createGoal(...)` | Create goal (12 params) |
| `contribute(goalId, playerId, amount)` | Atomic contribution (transaction) |
| `completeGoal(goalId)` | Mark completed |

**Missing Methods Needed:**
- `getGoal(goalId)` — single goal stream
- `leaveGoal(goalId, playerId)` — remove from goal
- `getCompletedGoals(playerId)` — history

---

## 6. PROVIDER / STATE MANAGEMENT ANALYSIS

### Architecture Pattern
- **Framework:** Riverpod (flutter_riverpod ^3.3.1)
- **Pattern:** `Provider<T>` for services, `StreamProvider.family.autoDispose` for reactive data, `FutureProvider.family.autoDispose` for one-shot queries
- **No Notifiers/StateNotifiers** except `ThemeModeNotifier` for theme

### All Existing Providers (55 total)

**File: `lib/services/firebase_service.dart` (4 providers)**
| Provider | Type | Consumers |
|----------|------|-----------|
| `firebaseAuthProvider` | `Provider<FirebaseAuth>` | `authServiceProvider`, any auth screen |
| `firestoreProvider` | `Provider<FirebaseFirestore>` | All service providers, inline providers |
| `storageProvider` | `Provider<FirebaseStorage>` | `authServiceProvider`, `videoAnalysisServiceProvider` |
| `authServiceProvider` | `Provider<AuthService>` | Auth screens, admin tabs |

**File: `lib/providers/auth_provider.dart` (3 providers)**
| Provider | Type | Consumers |
|----------|------|-----------|
| `authStateProvider` | `StreamProvider<User?>` | `role_router.dart`, `community_screen.dart`, `coach_dashboard.dart`, `academy_dashboard.dart`, `admin_dashboard.dart` |
| `userProfileProvider` | `FutureProvider.family<UserModel?, String>` | `role_router.dart` |
| `authLoadingProvider` | `Provider<bool>` (stub) | Not consumed anywhere |

**File: `lib/services/providers.dart` (41 providers)**
| Provider | Type | Consumers |
|----------|------|-----------|
| `venueServiceProvider` | `Provider<VenueService>` | `admin_dashboard.dart` |
| `chatServiceProvider` | `Provider<ChatService>` | `chat_detail_screen.dart` |
| `contractServiceProvider` | `Provider<ContractService>` | `contract_detail_screen.dart` |
| `coachServiceProvider` | `Provider<CoachService>` | `coach_discovery_screen.dart`, `coach_dashboard.dart` |
| `academyServiceProvider` | `Provider<AcademyService>` | `academy_coaches_tab.dart`, `batches_tab.dart`, `advertising_tab.dart`, `academy_jobs_tab.dart`, `academy_dashboard.dart` |
| `playerServiceProvider` | `Provider<PlayerService>` | `parent_dashboard.dart`, `performance_tab.dart` |
| `venuesStreamProvider` | `StreamProvider<List<VenueModel>>` | `admin_dashboard.dart`, `venue_discovery_screen.dart` |
| `venueProvider` | `StreamProvider.family<VenueModel, String>` | `venue_detail_screen.dart` |
| `userChatsProvider` | `StreamProvider.family<List<ChatModel>, String>` | `chat_list_screen.dart` |
| `chatMessagesProvider` | `StreamProvider.family<List<ChatMessage>, String>` | `chat_detail_screen.dart` |
| `userContractsProvider` | `StreamProvider.family<List<ContractModel>, String>` | `contract_list_screen.dart` |
| `contractProvider` | `StreamProvider.family<ContractModel, String>` | `contract_detail_screen.dart` |
| `coachesStreamProvider` | `StreamProvider<List<CoachModel>>` | `coach_discovery_screen.dart`, `academy_coaches_tab.dart` |
| `coachProvider` | `StreamProvider.family<CoachModel, String>` | `coach_dashboard.dart`, `academy_coaches_tab.dart`, `academy_dashboard.dart`, `coach_academy_jobs_screen.dart` |
| `academyProvider` | `StreamProvider.family<AcademyModel, String>` | `academy_dashboard.dart` |
| `parentPlayersProvider` | `StreamProvider.family<List<PlayerModel>, String>` | `parent_dashboard.dart`, `parent_progress_screen.dart` |
| `playerProvider` | `StreamProvider.family<PlayerModel, String>` | `performance_tab.dart`, `achievement_tab.dart`, `schedule_tab.dart`, `coach_dashboard.dart` |
| `playerMetricsProvider` | `StreamProvider.family<QuerySnapshot, String>` | `performance_tab.dart` |
| `playerSessionsProvider` | `StreamProvider.family<QuerySnapshot, String>` | (not consumed in UI) |
| `coachSessionsProvider` | `StreamProvider.family<QuerySnapshot, String>` | `schedule_tab.dart`, `earnings_tab.dart` |
| `coachPlayersProvider` | `StreamProvider.family<QuerySnapshot, String>` | `students_tab.dart` |
| `coachStatsProvider` | `FutureProvider.family<Map, String>` | `coach_dashboard.dart` |
| `coachMonthlyEarningsProvider` | `FutureProvider.family<Map, String>` | `coach_dashboard.dart` |
| `coachMilestonesProvider` | `StreamProvider.family<QuerySnapshot, String>` | `coach_dashboard.dart` |
| `academyBatchesProvider` | `StreamProvider.family<QuerySnapshot, String>` | `batches_tab.dart`, `academy_dashboard.dart` |
| `academyPlacementsProvider` | `StreamProvider.family<QuerySnapshot, String>` | `academy_dashboard.dart` |
| `academyCoachesProvider` | `StreamProvider.family<QuerySnapshot, String>` | `academy_coaches_tab.dart` |
| `activeCoachesCountProvider` | `FutureProvider.family<int, String>` | `academy_dashboard.dart` |
| `allUsersProvider` | `StreamProvider<QuerySnapshot>` | `users_tab.dart`, `admin_dashboard.dart` |
| `coachJobsProvider` | `StreamProvider<QuerySnapshot>` | `coach_academy_jobs_screen.dart` |
| `coachApplicationsProvider` | `StreamProvider.family<QuerySnapshot, String>` | `coach_academy_jobs_screen.dart` |
| `academyInvitationsProvider` | `StreamProvider.family<QuerySnapshot, String>` | `academy_coaches_tab.dart` |
| `coachInvitationsProvider` | `StreamProvider.family<QuerySnapshot, String>` | (not consumed in UI) |
| `academyJobsProvider` | `StreamProvider.family<QuerySnapshot, String>` | `academy_jobs_tab.dart` |
| `academyCampaignsProvider` | `StreamProvider.family<QuerySnapshot, String>` | `advertising_tab.dart` |
| `couponsProvider` | `StreamProvider<QuerySnapshot>` | `coupons_tab.dart`, `admin_dashboard.dart` |
| `adminTasksProvider` | `StreamProvider<QuerySnapshot>` | `admin_dashboard.dart` |
| `totalRevenueProvider` | `StreamProvider<double>` | `admin_dashboard.dart` |
| `activeUsersCountProvider` | `StreamProvider<int>` | `admin_dashboard.dart` |
| `playerAchievementsProvider` | `StreamProvider.family<List<Map>, String>` | `achievement_tab.dart` |
| `communityPostsProvider` | `StreamProvider<List<Map>>` | `community_screen.dart` |

**File: `lib/features/squad_goals/providers/squad_goals_providers.dart` (3 providers)**
| Provider | Type | Consumers |
|----------|------|-----------|
| `squadGoalsServiceProvider` | `Provider<SquadGoalsService>` | Squad goals screen |
| `activeSquadGoalsBySportProvider` | `StreamProvider.family<List<SquadGoal>, String>` | `squad_goals_screen.dart` |
| `playerSquadGoalsProvider` | `StreamProvider.family<List<SquadGoal>, String>` | `squad_goals_screen.dart` |

**File: `lib/features/video_analysis/providers/video_analysis_providers.dart` (3 providers)**
| Provider | Type | Consumers |
|----------|------|-----------|
| `videoAnalysisServiceProvider` | `Provider<VideoAnalysisService>` | Video analysis screen |
| `playerVideosProvider` | `StreamProvider.family<List<VideoAnalysisResult>, String>` | `video_analysis_screen.dart` |
| `latestVideoProvider` | `StreamProvider.family<VideoAnalysisResult?, String>` | `video_analysis_screen.dart` |

**File: `lib/core/theme/theme_provider.dart` (1 provider)**
| Provider | Type | Consumers |
|----------|------|-----------|
| `themeModeProvider` | `NotifierProvider<ThemeModeNotifier, ThemeMode>` | `app.dart`, `premium_shell.dart` |

### Missing Providers Needed

| Provider | Type | Purpose |
|----------|------|---------|
| `bookingServiceProvider` | `Provider<BookingService>` | Booking flow |
| `notificationServiceProvider` | `Provider<NotificationService>` | Push notifications |
| `paymentServiceProvider` | `Provider<PaymentService>` | Payment processing |
| `reviewServiceProvider` | `Provider<ReviewService>` | Reviews/ratings |
| `availabilityServiceProvider` | `Provider<AvailabilityService>` | Coach availability |
| `searchServiceProvider` | `Provider<SearchService>` | Server-side search |
| `currentUserProfileProvider` | `StreamProvider<UserModel>` | Current user reactive profile (used in every shell) |
| `bookingRequestsProvider` | `StreamProvider.family<List<Session>, String>` | Coach's incoming booking requests |
| `coachAvailabilityProvider` | `StreamProvider.family<Availability, String>` | Coach availability slots |
| `venueReviewsProvider` | `StreamProvider.family<List<Review>, String>` | Venue reviews |
| `coachReviewsProvider` | `StreamProvider.family<List<Review>, String>` | Coach reviews |
| `notificationCountProvider` | `StreamProvider.family<int, String>` | Unread notification count |
| `notificationsProvider` | `StreamProvider.family<List<Notification>, String>` | User notifications |
| `paymentHistoryProvider` | `StreamProvider.family<List<Payment>, String>` | User payment history |

---

## 7. NAVIGATION ANALYSIS

### All Routes

| Route | Screen | Role | Status |
|-------|--------|------|--------|
| `/` | `SplashScreen` | All | ✅ Working |
| `/login` | `LoginScreen` | All | ✅ Working |
| `/signup` | `SignupScreen` | All | ✅ Working |
| `/forgot-password` | `ForgotPasswordScreen` | All | ✅ Working |
| `/home` | `RoleRouter` → shells | All | ✅ Working |
| `/venues` | `VenueDiscoveryScreen` | Admin, Player | ✅ List only |
| `/venues/:id` | `VenueDetailScreen` | Admin, Player | ⚠️ Display only |
| `/chat` | `ChatListScreen` | All | ✅ Working |
| `/chat/:id` | `ChatDetailScreen` | All | ✅ Text only |
| `/coach-discovery` | `CoachDiscoveryScreen` | Player, Parent | ✅ Working |
| `/create-session` | `CreateSessionScreen` | Coach | ✅ Working |
| `/contracts` | `ContractListScreen` | All | ✅ Working |
| `/contracts/:id` | `ContractDetailScreen` | All | ✅ Sign works |

### Missing Routes Required

| Route | Screen | Purpose |
|-------|--------|---------|
| `/coach/:id` | `CoachDetailScreen` | Full coach profile, reviews, book |
| `/booking/:coachId` | `BookingFlowScreen` | Complete booking flow |
| `/session/:id` | `SessionDetailScreen` | Session details + actions |
| `/payment/:contractId` | `PaymentScreen` | Payment processing |
| `/batch/:id` | `BatchDetailScreen` | Batch students + management |
| `/student/:id` | `StudentDetailScreen` | Player detail for coach |
| `/notifications` | `NotificationCenterScreen` | In-app notifications |
| `/admin/users/:id` | `AdminUserDetailScreen` | User management |
| `/admin/venues` | `AdminVenueManagementScreen` | Venue CRUD |
| `/admin/analytics` | `AdminAnalyticsScreen` | Platform analytics |
| `/profile/edit` | `EditProfileScreen` | Profile editing |
| `/onboarding` | `OnboardingScreen` | First-time user flow |
| `/settings` | `SettingsScreen` | App settings |
| `/video/:id` | `VideoDetailScreen` | Video analysis detail |
| `/job/:id` | `JobDetailScreen` | Job detail + apply |
| `/application/:id` | `ApplicationDetailScreen` | Application status |
| `/community/post/:id` | `PostDetailScreen` | Post with comments |

---

## 8. UI IMPLEMENTATION ANALYSIS

### Design System Status

The project has **two competing design systems**:

| Aspect | `core/theme/` (Legacy) | `design_system/` (New) |
|--------|----------------------|----------------------|
| Colors | `AppColors` with gradients (7 gradients), primary=#3B82F6 | `AppColors` with 60+ semantic tokens, primary=#2563EB, dual dark/light |
| Typography | Poppins (display) + Inter (body) | Inter only + JetBrains Mono |
| Spacing | `AppDimensions` (xs=4 to xxxl=64) | `SpacingScale` (s2=2 to s80=80) + `SpacingTokens` |
| Widgets | 10 widgets (AppScaffold, GradientButton, GlassMorphism, etc.) | 28 widgets (PrimaryButton, GlassCard, AppAvatar, etc.) |
| Layouts | `AppScaffold`, `ResponsiveScaffold` | `PremiumShell`, `PremiumSidebar`, `PremiumDrawer`, `PremiumTopBar`, `AppBottomNav` |
| Theme | `AppTheme.dark` / `AppTheme.light` (ThemeData) | Token-based, no ThemeData |
| Used By | 12 feature screens (all non-player-dashboard screens) | Player dashboard + all shell/layout widgets |

### Reusable Components Available (from `design_system/`)

| Category | Components |
|----------|-----------|
| **Buttons** | PrimaryButton, SecondaryButton, OutlineButton, GhostButton, AppTextButton, GlassButton, AppIconButton, AppFloatingActionButton |
| **Inputs** | AppTextField, PasswordField, AppSearchBar, AppDropdown, SegmentControl |
| **Surfaces** | AppCard, GlassCard, StatCard, MetricCard, ShimmerLoading, AppProgressBar, AppCircularProgress |
| **Feedback** | AppSnackbar, AppToast, AppBottomSheet, AppDialog |
| **Misc** | AppAvatar (5 sizes), AppBadge (6 variants), NotificationBadge, Pill, AppTag, SectionHeader, AppTabBar, AppListTile, ProfileTile, EmptyState, ErrorState |
| **Layouts** | PremiumShell, PremiumSidebar/CollapsedSidebar, PremiumDrawer, PremiumTopBar, AppBottomNav, FloatingNav |

### Components Missing

- Calendar/DatePicker component (date picker used inline in multiple screens)
- Time slot picker
- Map widget wrapper
- Video player widget wrapper
- Rich text editor (for community posts)
- Image carousel/gallery
- Star rating input (display exists but not input)
- Price display component (INR formatting done inline everywhere)
- Booking card component
- Notification card component
- Review card component
- Session card component (duplicated across screens)
- Coach card component (duplicated in discovery + academy tabs)
- Job card component (duplicated in jobs tabs)

### Screens Requiring Redesign

| Screen | Issue |
|--------|-------|
| `coach_dashboard.dart` (985 lines) | Monolithic; needs decomposition into 5+ sub-widgets |
| `academy_dashboard.dart` (687 lines) | Monolithic; uses StreamBuilder alongside Riverpod |
| `admin_dashboard.dart` (603 lines) | Monolithic; venue form + coupon form embedded |
| `community_screen.dart` | Needs complete interaction layer |
| All admin screens | No responsive layout |

### Screens Using Old Theme Instead of Design System

Every screen EXCEPT `features/player/presentation/dashboard/` uses `core/theme/` imports:
- `auth/` screens (4 files)
- `home/` shell + tab files (22 files)
- `coach/` screens (2 files)
- `academy/` screen (1 file)
- `admin/` screen (1 file)
- `venue/` screens (2 files)
- `chat/` screens (2 files)
- `contracts/` screens (2 files)
- `community/` screen (1 file)

---

## 9. CODE CHANGE MAP

### Feature: Payment Integration

| Aspect | Files |
|--------|-------|
| **Files that must change** | `contract_service.dart`, `coach_dashboard.dart`, `coach_discovery_screen.dart` |
| **Files to create** | `lib/services/payment_service.dart`, `lib/providers/payment_providers.dart`, `lib/features/payment/presentation/payment_screen.dart`, `lib/features/payment/presentation/payment_success_screen.dart`, `lib/models/payment_model.dart` |
| **Models required** | `PaymentModel` (paymentId, userId, contractId, amount, currency, method, status, gatewayResponse, createdAt) |
| **Services required** | `PaymentService` (initiatePayment, verifyPayment, getPaymentHistory, processRefund) |
| **Providers required** | `paymentServiceProvider`, `paymentHistoryProvider` |
| **Screens required** | `PaymentScreen`, `PaymentSuccessScreen`, `PaymentHistoryScreen` |

### Feature: Notification System

| Aspect | Files |
|--------|-------|
| **Files that must change** | `main.dart`, `app.dart`, all shells, `premium_top_bar.dart` |
| **Files to create** | `lib/services/notification_service.dart`, `lib/providers/notification_providers.dart`, `lib/features/notifications/presentation/notification_center_screen.dart`, `lib/features/notifications/presentation/widgets/notification_tile.dart`, `lib/models/notification_model.dart` |
| **Models required** | `NotificationModel` (id, userId, title, body, type, read, data, createdAt) |
| **Services required** | `NotificationService` (initialize, getToken, sendNotification, getUserNotifications, markAsRead, markAllRead) |
| **Providers required** | `notificationServiceProvider`, `notificationsProvider`, `unreadNotificationCountProvider` |
| **Screens required** | `NotificationCenterScreen` |

### Feature: Booking Flow

| Aspect | Files |
|--------|-------|
| **Files that must change** | `coach_service.dart`, `coach_discovery_screen.dart`, `coach_dashboard.dart`, `schedule_tab.dart` |
| **Files to create** | `lib/services/booking_service.dart`, `lib/features/booking/presentation/booking_flow_screen.dart`, `lib/features/booking/presentation/booking_confirmation_screen.dart`, `lib/features/booking/presentation/widgets/availability_calendar.dart`, `lib/features/booking/presentation/widgets/time_slot_picker.dart` |
| **Models required** | Extend `sessions` with bookingStatus field; create `AvailabilityModel` |
| **Services required** | `BookingService` (createBooking, acceptBooking, rejectBooking, cancelBooking, getAvailability) |
| **Providers required** | `bookingServiceProvider`, `bookingRequestsProvider`, `coachAvailabilityProvider` |
| **Screens required** | `BookingFlowScreen`, `BookingConfirmationScreen` |

### Feature: Coach Detail + Reviews

| Aspect | Files |
|--------|-------|
| **Files that must change** | `app_router.dart`, `coach_discovery_screen.dart` |
| **Files to create** | `lib/features/coach/presentation/coach_detail_screen.dart`, `lib/services/review_service.dart`, `lib/models/review_model.dart`, `lib/features/coach/presentation/widgets/coach_reviews_section.dart`, `lib/features/coach/presentation/widgets/coach_availability_section.dart` |
| **Models required** | `ReviewModel` (reviewId, reviewerId, targetId, targetType, rating, comment, sessionId, createdAt) |
| **Services required** | `ReviewService` (addReview, getCoachReviews, getVenueReviews) |
| **Providers required** | `coachReviewsProvider`, `venueReviewsProvider` |
| **Screens required** | `CoachDetailScreen` |

### Feature: Attendance Tracking

| Aspect | Files |
|--------|-------|
| **Files that must change** | `coach_service.dart`, `schedule_tab.dart`, `coach_dashboard.dart` |
| **Files to create** | `lib/services/attendance_service.dart`, `lib/features/schedule/presentation/attendance_screen.dart` |
| **Models required** | `AttendanceModel` (sessionId, playerId, checkedIn, checkedOut, status) |
| **Services required** | `AttendanceService` (checkIn, checkOut, getSessionAttendance, getAttendanceReport) |
| **Providers required** | `sessionAttendanceProvider` |
| **Screens required** | `AttendanceScreen` |

### Feature: Admin User Management

| Aspect | Files |
|--------|-------|
| **Files that must change** | `auth_service.dart`, `users_tab.dart`, `admin_dashboard.dart` |
| **Files to create** | `lib/features/admin/presentation/admin_user_detail_screen.dart`, `lib/features/admin/presentation/admin_venue_management_screen.dart` |
| **Models required** | None new |
| **Services required** | Add `banUser()`, `verifyUser()`, `deleteUser()` to `AuthService` |
| **Providers required** | `adminUserDetailProvider` |
| **Screens required** | `AdminUserDetailScreen`, `AdminVenueManagementScreen` |

### Feature: Parent-Child Linking

| Aspect | Files |
|--------|-------|
| **Files that must change** | `auth_service.dart`, `signup_screen.dart`, `parent_shell.dart` |
| **Files to create** | `lib/features/parent_player/presentation/add_child_screen.dart`, `lib/features/parent_player/presentation/child_profile_screen.dart`, `lib/services/parent_service.dart` |
| **Models required** | None new (extends PlayerModel usage) |
| **Services required** | `ParentService` (addChild, linkChild, getChild, updateChild) |
| **Providers required** | `parentServiceProvider`, `currentChildProvider` |
| **Screens required** | `AddChildScreen`, `ChildProfileScreen` |

### Feature: Onboarding Wizard

| Aspect | Files |
|--------|-------|
| **Files that must change** | `role_router.dart`, `auth_service.dart` |
| **Files to create** | `lib/features/onboarding/presentation/onboarding_screen.dart`, `lib/features/onboarding/presentation/widgets/role_specific_step.dart`, `lib/features/onboarding/presentation/widgets/sport_selection_step.dart` |
| **Models required** | None new |
| **Services required** | Add `completeOnboarding(uid)` to `AuthService` |
| **Providers required** | `onboardingStatusProvider` |
| **Screens required** | `OnboardingScreen` |

### Feature: Availability Calendar

| Aspect | Files |
|--------|-------|
| **Files that must change** | `coach_service.dart` |
| **Files to create** | `lib/models/availability_model.dart`, `lib/services/availability_service.dart`, `lib/features/availability/presentation/availability_editor_screen.dart`, `lib/features/availability/presentation/widgets/time_slot_picker.dart` |
| **Models required** | `AvailabilityModel` (coachId, slots per day, exceptions) |
| **Services required** | `AvailabilityService` (getAvailability, updateAvailability, getAvailableSlots) |
| **Providers required** | `coachAvailabilityProvider` |
| **Screens required** | `AvailabilityEditorScreen` |

---

## 10. IMPLEMENTATION PRIORITY ROADMAP

### Priority 0: Things Blocking All Development

| Task | Reason | Files | Dependencies | Difficulty | Expected Outcome |
|------|--------|-------|-------------|------------|-----------------|
| **Create production Firebase project** | Current project is `auth-for-docs` (test project); `com.example.coachBooking` bundle ID | `firebase_options.dart`, `ios/`, `android/`, `.firebaserc` | None | Low | Production-ready Firebase config |
| **Extract `_parseTimestamp()` to shared utility** | Duplicated in all 8 model files; blocks model refactoring | All files in `models/`, create `lib/core/utils/date_parser.dart` | None | Low | Single source of truth for timestamp parsing |
| **Consolidate design systems** | Two competing `AppColors` classes, two spacing systems, two widget sets | `core/theme/`, `design_system/`, all feature screens | None | High | One consistent design system |
| **Fix `authLoadingProvider` stub** | Always returns false; breaks any loading state UX | `lib/providers/auth_provider.dart` | None | Low | Real loading state tracking |
| **Fix `assignStudentToBatch()` bug** | `studentId` parameter unused; breaks enrollment | `lib/services/academy_service.dart` | None | Low | Student ID actually stored |

### Priority 1: Core Marketplace Flow

| Task | Reason | Files | Dependencies | Difficulty | Expected Outcome |
|------|--------|-------|-------------|------------|-----------------|
| **Payment Gateway Integration** | Revenue model depends on it; contracts are useless without payment | New: `payment_service.dart`, `payment_model.dart`, `payment_screen.dart`; Modify: `contract_service.dart`, `coach_discovery_screen.dart` | Priority 0 | High | End-to-end booking → payment → contract |
| **Booking Flow Screen** | Current booking is a minimal bottom sheet; needs proper flow | New: `booking_flow_screen.dart`, `availability_calendar.dart`; Modify: `coach_service.dart`, `coach_discovery_screen.dart` | Payment | High | Full booking experience |
| **Coach Detail Screen** | Players cannot evaluate coaches before booking | New: `coach_detail_screen.dart`, `review_model.dart`, `review_service.dart`; Modify: `app_router.dart` | None | Medium | Informed booking decisions |
| **Accept/Reject Booking (Coach)** | Coaches cannot manage incoming requests | New: `booking_requests_screen.dart`; Modify: `coach_service.dart`, `schedule_tab.dart` | Booking Flow | Medium | Coach booking management |
| **Session Detail + Actions** | Sessions are display-only; cannot be managed | New: `session_detail_screen.dart`; Modify: `coach_service.dart`, `schedule_tab.dart` | None | Medium | Session lifecycle management |
| **Notification Service** | Critical for all booking/contract/session events | New: `notification_service.dart`, `notification_model.dart`, `notification_center_screen.dart`; Modify: `main.dart`, shells | None | High | Push + in-app notifications |
| **Availability Calendar** | Players cannot see when coaches are free; booking flow needs it | New: `availability_model.dart`, `availability_service.dart`, `availability_editor_screen.dart`; Modify: `coach_service.dart` | None | Medium | Coach schedule visibility |
| **Parent-Child Linking** | Parents who sign up after children cannot link accounts | New: `add_child_screen.dart`, `parent_service.dart`; Modify: `role_router.dart` | None | Medium | Parent can manage children |

### Priority 2: Engagement Features

| Task | Reason | Files | Dependencies | Difficulty | Expected Outcome |
|------|--------|-------|-------------|------------|-----------------|
| **Community Interactions** | Social features are core to retention | Modify: `community_screen.dart`, create `lib/services/community_service.dart` | Notification Service | Medium | Like/comment/share working |
| **Community Media Attachments** | Posts without media have low engagement | Modify: `community_screen.dart`; add to `community_service.dart` | None | Medium | Image/video in posts |
| **Venue Booking** | Venue discovery exists but cannot book | New: `venue_booking_screen.dart`; Modify: `venue_service.dart`, `venue_detail_screen.dart` | Payment | High | Venue reservation |
| **Map Integration** | Google Maps declared but unused | New: `map_screen.dart`; Modify: `venue_discovery_screen.dart`, `coach_discovery_screen.dart` | None | Medium | Location-based discovery |
| **Admin User Management** | Users list is read-only; cannot moderate | Modify: `users_tab.dart`, `auth_service.dart`; New: `admin_user_detail_screen.dart` | None | Low | Platform moderation |
| **Performance Metrics Expansion** | Log form (4 types) doesn't match chart (5 types) | Modify: `parent_dashboard.dart`, `performance_tab.dart` | None | Low | Consistent metric tracking |
| **Chat Enhancements** | Basic text-only; missing key UX features | Modify: `chat_service.dart`, `chat_detail_screen.dart` | Notification Service | Medium | Rich messaging |

### Priority 3: Business Features

| Task | Reason | Files | Dependencies | Difficulty | Expected Outcome |
|------|--------|-------|-------------|------------|-----------------|
| **Subscription Payment** | Coach monetization model | Modify: `coach_dashboard.dart`, `coach_service.dart` | Payment Gateway | Medium | Coach plan upgrades |
| **Attendance Tracking** | Session quality assurance | New: `attendance_service.dart`, `attendance_screen.dart`; Modify: `coach_service.dart` | Session Detail | Medium | Session attendance records |
| **Job Portal Enhancement** | Incomplete job lifecycle | Modify: `academy_jobs_tab.dart`, `coach_academy_jobs_screen.dart`, `academy_service.dart` | None | Low | Full job workflow |
| **Academy Batch Enrollment** | Cannot enroll students in batches | Modify: `batches_tab.dart`, `academy_service.dart` | None | Low | Student-batch assignment |
| **Onboarding Wizard** | First-time user experience | New: `onboarding_screen.dart`; Modify: `role_router.dart` | None | Medium | Guided first experience |
| **Gamification Engine** | Points/achievements are static; no automatic earning | New: `gamification_service.dart`; Modify: `player_service.dart` | None | High | Automatic reward system |
| **Video Analysis (Real AI)** | Currently mock; no actual analysis | Modify: `video_analysis_service.dart` | None | Very High | AI-powered form analysis |
| **Admin Analytics** | No platform insights | New: `admin_analytics_screen.dart`; Modify: `admin_dashboard.dart` | None | Medium | Data-driven decisions |

### Priority 4: Production Readiness

| Task | Reason | Files | Dependencies | Difficulty | Expected Outcome |
|------|--------|-------|-------------|------------|-----------------|
| **Error Handling Layer** | No consistent error handling pattern | New: `lib/core/utils/result.dart`; Modify: all services | None | Medium | `Result<T>` wrapper pattern |
| **Firestore Security Rules** | Current catch-all is too permissive | `firestore.rules` | None | Medium | Role-based access control |
| **Tests** | No tests exist | All service and model files | None | High | 80%+ coverage |
| **Localization** | All strings hardcoded | All screen files | None | High | English + Hindi |
| **Analytics/Crash Reporting** | No monitoring | `main.dart`, all error paths | Firebase project | Low | Crashlytics + Analytics |
| **CI/CD Pipeline** | No automated builds | `.github/workflows/` or `codemagic.yaml` | Git repo | Medium | Automated build + deploy |
| **Offline Support** | No caching | All services | None | High | Firestore offline persistence |
| **Performance Optimization** | Client-side search, large monolithic files | All services, large dashboard files | None | Medium | Scalable architecture |

---

## 11. FIRST 10 IMPLEMENTATION TASKS

### 1. Extract `_parseTimestamp()` to Shared Utility

**Files:** Create `lib/core/utils/date_parser.dart`; Modify all 8 files in `lib/models/`
**Why first:** Zero risk, zero dependencies, eliminates code duplication across every model. Quick win that cleans up the foundation.

### 2. Fix `assignStudentToBatch()` Bug

**Files:** Modify `lib/services/academy_service.dart`
**Why second:** One-line fix (`studentId` parameter is unused). Critical for academy batch enrollment to work. Blocks Priority 2 academy features.

### 3. Fix `authLoadingProvider` Stub

**Files:** Modify `lib/providers/auth_provider.dart`
**Why third:** Current implementation always returns false. Replace with a StateNotifier that tracks actual auth loading state. Improves UX immediately on login/signup.

### 4. Create Coach Detail Screen

**Files:** Create `lib/features/coach/presentation/coach_detail_screen.dart`, `lib/models/review_model.dart`, `lib/services/review_service.dart`; Modify `lib/core/routing/app_router.dart`
**Why fourth:** Players have no way to evaluate coaches before booking. This is the first screen in the booking funnel. No external dependencies needed.

### 5. Create Payment Model and Service (Skeleton)

**Files:** Create `lib/models/payment_model.dart`, `lib/services/payment_service.dart`, `lib/providers/payment_providers.dart`
**Why fifth:** Establishes the data layer for payments before building the UI. Enables downstream booking flow and contract completion.

### 6. Create Notification Service (Skeleton)

**Files:** Create `lib/services/notification_service.dart`, `lib/models/notification_model.dart`, `lib/providers/notification_providers.dart`; Modify `lib/main.dart`
**Why sixth:** Every future feature (bookings, contracts, sessions) needs notification infrastructure. Setting up the service early means all subsequent features can emit notifications immediately.

### 7. Create Availability Model and Service

**Files:** Create `lib/models/availability_model.dart`, `lib/services/availability_service.dart`; Modify `lib/services/coach_service.dart`
**Why seventh:** The booking flow screen (Task 8) requires coach availability data. This establishes the availability data model.

### 8. Create Booking Flow Screen

**Files:** Create `lib/features/booking/presentation/booking_flow_screen.dart`, `lib/features/booking/presentation/widgets/availability_calendar.dart`, `lib/features/booking/presentation/widgets/time_slot_picker.dart`; Modify `lib/features/home/presentation/coach_discovery_screen.dart`
**Why eighth:** Replaces the current minimal bottom-sheet booking with a proper flow. Depends on payment model (5), notification service (6), and availability (7).

### 9. Create Coach Accept/Reject Booking UI

**Files:** Create `lib/features/schedule/presentation/booking_requests_screen.dart`; Modify `lib/services/coach_service.dart`, `lib/features/home/presentation/schedule_tab.dart`
**Why ninth:** Completes the booking cycle. After a player books (8), the coach needs to accept/reject. Depends on booking flow and notification service.

### 10. Create Session Detail Screen with Actions

**Files:** Create `lib/features/schedule/presentation/session_detail_screen.dart`; Modify `lib/services/coach_service.dart`
**Why tenth:** Both coaches and players need to view session details and take actions (cancel, reschedule, complete, mark attendance). Depends on booking flow and notifications.

---

## 12. ARCHITECTURE RULES FOR FUTURE DEVELOPMENT

### Where New Screens Should Go

```
lib/features/<feature_name>/
├── presentation/
│   ├── <feature>_screen.dart          # Main screen
│   └── widgets/
│       ├── <sub_component>.dart       # Reusable sub-widgets
│       └── ...
├── data/
│   └── <feature>_service.dart         # Feature-specific service
└── providers/
    └── <feature>_providers.dart       # Feature-specific providers
```

**Exception:** Services that are shared across features go in `lib/services/`. Models go in `lib/models/`.

### Where Providers Should Live

| Provider Type | Location |
|--------------|----------|
| Firebase singletons + AuthService | `lib/services/firebase_service.dart` |
| Auth state | `lib/providers/auth_provider.dart` |
| Domain service providers + data providers | `lib/services/providers.dart` (for now; eventually split per feature) |
| Feature-specific providers | `lib/features/<feature>/providers/` |
| Theme | `lib/core/theme/theme_provider.dart` |

### Where Services Should Be Added

- **Cross-feature services** (auth, chat, notification): `lib/services/`
- **Feature-specific services** (video analysis, squad goals): `lib/features/<feature>/data/`
- All services receive `FirebaseFirestore` via constructor injection from Riverpod

### Which Design System to Use

**ALWAYS use `design_system/` for new code.** Never import from `core/theme/app_colors.dart` or `core/theme/app_text_styles.dart` for new screens. The migration from `core/` to `design_system/` is ongoing but all new work must use the new system.

Import pattern:
```dart
import 'package:sports_app/design_system/design_system.dart';
```

This single import gives access to all tokens, colors, typography, widgets, layouts, responsive helpers, and extensions.

### How Models Should Be Created

1. Create file in `lib/models/<model_name>_model.dart`
2. Include `fromDoc(DocumentSnapshot)` factory for Firestore deserialization
3. Include `toMap()` method for Firestore serialization
4. Use `FieldValue.serverTimestamp()` for `updatedAt`
5. Use `Timestamp.fromDate()` for DateTime fields sent to Firestore
6. Use shared `_parseTimestamp()` from `lib/core/utils/date_parser.dart`
7. Include `copyWith()` method for immutable updates
8. Document all fields with their Firestore equivalents

### Error Handling Pattern

Currently no consistent pattern. Adopt this for all new code:

```dart
// Service method pattern
Future<Result<T>> someMethod() async {
  try {
    final result = await _firestore.collection('...').get();
    return Result.success(data);
  } on FirebaseException catch (e) {
    return Result.failure('Error message: ${e.message}');
  } catch (e) {
    return Result.failure('Unexpected error: $e');
  }
}
```

Create `lib/core/utils/result.dart` with:
```dart
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  Result.success(this.data) : error = null, isSuccess = true;
  Result.failure(this.error) : data = null, isSuccess = false;
}
```

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files (screens) | `snake_case_screen.dart` | `coach_detail_screen.dart` |
| Files (services) | `snake_case_service.dart` | `booking_service.dart` |
| Files (models) | `snake_case_model.dart` | `payment_model.dart` |
| Files (providers) | `snake_case_providers.dart` | `booking_providers.dart` |
| Widget classes | `PascalCase` | `CoachDetailScreen` |
| Provider names | `camelCase` + suffix | `bookingServiceProvider`, `coachReviewsProvider` |
| Service methods | `camelCase` verbs | `getBooking()`, `createBooking()`, `updateBooking()` |
| Firestore collections | `camelCase` (plural) | `bookings`, `coachReviews` |
| Route paths | `kebab-case` | `/coach-detail/:id` |

### State Management Rules

1. Use `StreamProvider.family.autoDispose` for Firestore streams
2. Use `FutureProvider.family.autoDispose` for one-shot queries
3. Use `Provider<T>` for service singletons
4. Never query Firestore directly in UI widgets — always go through a service
5. Never use `StreamBuilder` alongside Riverpod — use providers consistently
6. All providers must be in a `_providers.dart` file, not inline in widgets

### Widget Rules

1. Maximum 300 lines per widget file. Decompose into sub-widgets if larger.
2. Extract repeated card/list-item patterns into shared widgets in `lib/design_system/widgets/` or feature-local `widgets/` folder.
3. All screens must handle loading (`AsyncValue.when`), error, and empty states.
4. Use `flutter_animate` for entrance animations (consistent with existing pattern).
5. Use `SpacingScale` for all padding/margin. Never use magic numbers.

---

## 13. FINAL RECOMMENDATION

**If I were responsible for delivering SportsEco to production, I would implement in this order:**

### Phase 1: Foundation (Week 1)
1. Create production Firebase project (replacing `auth-for-docs`)
2. Extract shared utilities (`_parseTimestamp`, `Result<T>` pattern)
3. Fix known bugs (authLoadingProvider, assignStudentToBatch)
4. Establish notification service skeleton

### Phase 2: Core Marketplace (Weeks 2-3)
5. Coach Detail Screen with reviews section
6. Payment gateway integration (Razorpay for India)
7. Complete booking flow (availability → selection → payment → contract)
8. Coach accept/reject booking management
9. Session lifecycle (detail, cancel, reschedule, complete)

**Why payment first:** The app's revenue model is transaction-based (10% platform fee on contracts). Without payment integration, every other feature is a demo, not a product. The booking → payment → contract flow is the core loop that generates revenue and proves the marketplace model.

### Phase 3: Engagement (Week 4)
10. Notification system (push + in-app)
11. Community interactions (like, comment, share)
12. Venue booking
13. Map-based discovery

### Phase 4: Polish (Week 5)
14. Onboarding wizard
15. Admin management tools
16. Performance optimizations
17. Error handling standardization

### Phase 5: Scale (Week 6+)
18. Tests
19. Localization
20. Analytics
21. CI/CD

**The single most impactful feature to implement right now is the Payment Gateway.** It:
- Unlocks the core revenue model
- Makes contracts meaningful
- Validates the marketplace concept
- Is required before any user acquisition
- Touches the most critical user journey (booking → payment → training)

---

*End of IMPLEMENTATION_CONTEXT.md*
