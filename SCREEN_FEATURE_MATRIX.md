# SCREEN_FEATURE_MATRIX.md

> **Generated:** July 21, 2026  
> **Project:** SportsEco (Sports Ecosystem Platform)  
> **Purpose:** Complete inventory of every screen and feature with implementation status

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Fully Working |
| ⚠️ | Partially Working (UI exists, backend incomplete or stubs) |
| ❌ | Missing (not implemented) |

---

## 1. Authentication Screens

---

### 1.1 Splash Screen

```
Screen Name:    Splash Screen
File Path:      lib/features/auth/presentation/splash_screen.dart
User Role:      All (unauthenticated)
Navigation Route: / (initial route)
Purpose:        App branding display, auth state check, automatic redirect
Current UI Status: ✅ Fully implemented
Data Source:    FirebaseAuth.currentUser, authStateProvider
Firebase Collections Used: None (reads auth state only)
Providers Used: authStateProvider
Services Used:  None (direct FirebaseAuth fallback)
Implemented Features:
  - Animated gradient background with decorative circles
  - SportsEco logo with elastic scale animation
  - App name and tagline with fade-in animations
  - Loading spinner indicator
  - 2-second minimum display timer
  - Auth state check with auto-redirect to /home or /login
  - Fallback to FirebaseAuth.instance.currentUser if stream not ready
Missing Features: Branding animation asset (lottie) not used
Hardcoded/Dummy Data: None
Known Bugs: Race condition possible if auth state stream is slow
Production Readiness: ✅ Ready
```

### 1.2 Login Screen

```
Screen Name:    Login Screen
File Path:      lib/features/auth/presentation/login_screen.dart
User Role:      All (unauthenticated)
Navigation Route: /login
Purpose:        User authentication via email/password or Google
Current UI Status: ✅ Fully implemented
Data Source:    User input (email, password)
Firebase Collections Used: users (via AuthService.getUserProfile on success)
Providers Used: authServiceProvider
Services Used:  AuthService.signIn(), AuthService.signInWithGoogle()
Implemented Features:
  - Email + password form with validation (required, @ check, min 6 chars)
  - Password visibility toggle
  - "Forgot Password?" link → /forgot-password
  - "Sign Up" link → /signup
  - Google Sign-In button with loading states
  - Error handling with SnackBar messages
  - Animated entrance effects (flutter_animate)
  - Gradient button with loading indicator
  - Navigation to /home on success
Missing Features: Biometric auth, phone OTP login, "remember me" toggle
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 1.3 Signup Screen

```
Screen Name:    Signup Screen
File Path:      lib/features/auth/presentation/signup_screen.dart
User Role:      All (unauthenticated)
Navigation Route: /signup
Purpose:        New user registration with role selection (3-step wizard)
Current UI Status: ✅ Fully implemented
Data Source:    User input (role, name, email, phone, password)
Firebase Collections Used: users, coaches, academies, players (via AuthService.signUp)
Providers Used: authServiceProvider
Services Used:  AuthService.signUp()
Implemented Features:
  - Step 1: Role selection (Parent, Player, Coach, Academy) with animated cards
  - Step 2: Personal info (name, email, phone) with validation
  - Step 3: Password creation with terms acceptance
  - Step indicator (3 circles with progress bar)
  - Back/Forward navigation between steps
  - Form validation at each step (email regex, phone 10 digits, password min 6)
  - Error handling with SnackBar
  - Animated entrance effects per step
  - Navigation to /home on success
Missing Features: Onboarding wizard (post-signup), profile photo upload step, city selection step, Admin role not selectable
Hardcoded/Dummy Data: Admin role excluded from selection options
Known Bugs: None
Production Readiness: ✅ Ready
```

### 1.4 Forgot Password Screen

```
Screen Name:    Forgot Password Screen
File Path:      lib/features/auth/presentation/forgot_password_screen.dart
User Role:      All (unauthenticated)
Navigation Route: /forgot-password
Purpose:        Password reset via email
Current UI Status: ✅ Fully implemented
Data Source:    User input (email)
Firebase Collections Used: None (Firebase Auth handles reset email)
Providers Used: authServiceProvider
Services Used:  AuthService.sendPasswordResetEmail()
Implemented Features:
  - Email input field
  - Send reset link button with loading state
  - Success state with animated check icon
  - "Back to Login" button after success
  - Error handling with SnackBar
  - Animated entrance effects
Missing Features: None
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

---

## 2. Player Portal

---

### 2.1 Player Shell

```
Screen Name:    Player Shell (Navigation Container)
File Path:      lib/features/home/presentation/player_shell.dart
User Role:      Player
Navigation Route: /home (when role == player)
Purpose:        Role-specific navigation shell with 8 bottom tabs
Current UI Status: ✅ Fully implemented
Data Source:    UserModel (from auth flow)
Firebase Collections Used: None (navigation only)
Providers Used: authStateProvider, userProfileProvider
Services Used:  AuthService (for user profile)
Implemented Features:
  - 8-tab bottom navigation: Dashboard, Performance, AI Coach, Community, Chat, Coaches, Squad Goals, Profile
  - Uses PremiumShell (responsive: mobile bottom nav, tablet collapsed sidebar, desktop full sidebar)
  - Role label "Player" displayed in shell
  - Theme toggle in sidebar/drawer
  - Sign out functionality
Missing Features: Badge counts on tabs (notifications, unread messages)
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 2.2 Player Dashboard

```
Screen Name:    Player Dashboard
File Path:      lib/features/player/presentation/dashboard/dashboard_page.dart
User Role:      Player
Navigation Route: Dashboard tab (index 0 in PlayerShell)
Purpose:        Main player hub with KPIs, sessions, performance, achievements
Current UI Status: ✅ Fully implemented (3,888 lines across 14 files)
Data Source:    Firestore (players collection, sessions, playerMetrics, playerAchievements, posts)
Firebase Collections Used: players, sessions, playerMetrics, playerAchievements, posts
Providers Used: playerProvider, playerMetricsProvider, playerAchievementsProvider, communityPostsProvider
Services Used:  PlayerService, CoachService (for session data)
Implemented Features:
  - Hero section: greeting, player name, motivational quote, training day count, level/XP bar, streak badge
  - Today's Focus: daily rotating focus topic (based on day-of-year)
  - Daily Missions: 5 missions with XP rewards and completion animations
  - Player Progression: weekly XP, monthly XP, rank, personal best, consistency %, sparkline chart
  - Upcoming Session: next session card with date, time, venue, capacity, coach chat link
  - Quick Actions: 6-card grid (Book Venue, Find Coach, Community, Performance, Sessions, Goals)
  - Performance Section: fl_chart line chart, avg score badge, weekly trend
  - Insights Section: consistency score, weekly activity, rotating AI tip
  - Achievements Section: horizontal scrolling achievement badges
  - Community Section: trending challenge, recent community users
  - Bottom Section: rotating daily content strip (quote/tip/fact/nutrition)
  - Loading shimmer states
  - Empty state display
  - Responsive layout (Desktop, Tablet, Phone)
Missing Features: Real AI insights (currently hardcoded rotation), push notification integration
Hardcoded/Dummy Data:
  - Motivational quotes array (hardcoded)
  - Daily missions are static (not user-specific)
  - AI tips are hardcoded rotation
  - Community section shows random users (not real data)
  - Today's focus rotates by day-of-year, not personalized
Known Bugs: None
Production Readiness: ⚠️ Functional but many sections use hardcoded/rotating data
```

### 2.3 Performance Tab

```
Screen Name:    Performance Tab
File Path:      lib/features/home/presentation/performance_tab.dart
User Role:      Player
Navigation Route: Performance tab (index 1 in PlayerShell)
Purpose:        Track and visualize player performance metrics
Current UI Status: ✅ Fully implemented (593 lines)
Data Source:    Firestore (players, playerMetrics collections)
Firebase Collections Used: players, playerMetrics
Providers Used: playerProvider, playerMetricsProvider, playerServiceProvider
Services Used:  PlayerService.logMetric(), PlayerService.getPlayer()
Implemented Features:
  - Stats row: Level, XP, Rank mini cards
  - Line chart (fl_chart) for selected metric over time
  - 5 metric types: Speed (km/h), Stamina (%), Technique (%), Strength (kg), Agility (sec)
  - Metric type selector chips
  - Best value badge
  - Recent sessions list with metric values and timestamps
  - "Log New Session" bottom sheet with:
    - Metric type selection (ChoiceChip)
    - Value input with unit display
    - Save to Firestore via PlayerService.logMetric()
  - Empty state with "Log First Session" CTA
  - Loading shimmer states
  - Error state handling
Missing Features: Multi-metric comparison, goal-based tracking, export data, coach annotations
Hardcoded/Dummy Data: None (all data from Firestore)
Known Bugs: None
Production Readiness: ✅ Ready
```

### 2.4 AI Coach (Video Analysis)

```
Screen Name:    AI Coach / Video Analysis Screen
File Path:      lib/features/video_analysis/presentation/video_analysis_screen.dart
User Role:      Player
Navigation Route: AI Coach tab (index 2 in PlayerShell)
Purpose:        Upload training videos for AI-powered form analysis
Current UI Status: ✅ Fully implemented
Data Source:    Firebase Storage (video uploads), Firestore (videoAnalysis collection)
Firebase Collections Used: videoAnalysis
Providers Used: videoAnalysisServiceProvider, playerVideosProvider, latestVideoProvider
Services Used:  VideoAnalysisService (upload, list, delete videos)
Implemented Features:
  - Video upload via image_picker
  - Video list with thumbnail placeholders
  - Upload progress indicator
  - Video metadata (upload date, sport, analysis status)
  - Delete video functionality
  - Empty state display
Missing Features: Actual AI analysis engine (no ML integration), video playback, analysis results display, coach feedback on video
Hardcoded/Dummy Data: Analysis results are placeholder/mock
Known Bugs: None
Production Readiness: ⚠️ UI works but no real AI analysis backend
```

### 2.5 Community Feed

```
Screen Name:    Community Screen
File Path:      lib/features/community/presentation/community_screen.dart
User Role:      Player, Coach (shared tab)
Navigation Route: Community tab (index 3 in PlayerShell)
Purpose:        Social feed for community interaction
Current UI Status: ⚠️ Partially implemented (355 lines)
Data Source:    Firestore (posts collection)
Firebase Collections Used: posts
Providers Used: communityPostsProvider, authServiceProvider, firestoreProvider
Services Used:  None (direct Firestore writes)
Implemented Features:
  - Post composer with text input
  - "Post" button creating Firestore document
  - Post cards with author avatar (colored initial), name, role, content, timestamp
  - Like/comment/share action buttons (UI only)
  - Empty state "No community posts yet"
  - Loading state
  - Error state
Missing Features:
  - ❌ Like functionality (shows "coming soon" SnackBar)
  - ❌ Comment functionality (shows "coming soon" SnackBar)
  - ❌ Share functionality (shows "coming soon" SnackBar)
  - ❌ Image attachment (shows "coming soon" SnackBar)
  - ❌ Video attachment (shows "coming soon" SnackBar)
  - ❌ Emoji picker (shows "coming soon" SnackBar)
  - ❌ Post detail view
  - ❌ User profile from post
Hardcoded/Dummy Data: Author role hardcoded as 'player' on post creation
Known Bugs: authorRole always set to 'player' regardless of actual user role
Production Readiness: ⚠️ Basic posting works, interactions are stubs
```

### 2.6 Coach Discovery

```
Screen Name:    Coach Discovery Screen
File Path:      lib/features/home/presentation/coach_discovery_screen.dart
User Role:      Player, Parent
Navigation Route: Coaches tab (index 5 in PlayerShell, index 1 in ParentShell)
Purpose:        Search and browse coaches
Current UI Status: ✅ Fully implemented (588 lines)
Data Source:    Firestore (coaches collection)
Firebase Collections Used: coaches
Providers Used: coachesStreamProvider
Services Used:  CoachService.getCoaches()
Implemented Features:
  - Coach list with profile cards (photo, name, specialization, rating, hourly rate)
  - Search by name/specialization/city (client-side filter)
  - Sport filter chips
  - Verified badge display
  - Subscription tier display
  - Animated card entrance effects
  - Empty state
  - Loading state
  - Error state with retry
Missing Features:
  - ❌ Dedicated coach detail/profile screen (inline cards only)
  - ❌ Booking flow from discovery
  - ❌ Reviews/ratings section
  - ❌ Availability calendar
  - ❌ Distance-based sorting
Hardcoded/Dummy Data: None (real Firestore data)
Known Bugs: Client-side search won't scale with many coaches
Production Readiness: ⚠️ Functional but needs detail screen and booking flow
```

### 2.7 Squad Goals

```
Screen Name:    Squad Goals Screen
File Path:      lib/features/squad_goals/presentation/squad_goals_screen.dart
User Role:      Player
Navigation Route: Squad Goals tab (index 6 in PlayerShell)
Purpose:        Team-based athletic goal tracking
Current UI Status: ✅ Fully implemented (413 lines)
Data Source:    Firestore (squadGoals collection via local service)
Firebase Collections Used: squadGoals
Providers Used: squadGoalsServiceProvider, activeSquadGoalsBySportProvider, playerSquadGoalsProvider
Services Used:  SquadGoalsService (CRUD, join, progress update)
Implemented Features:
  - Create squad goal bottom sheet (title, description, sport, metric, target, deadline, members)
  - Sport-specific metrics (Cricket→Runs, Football→Goals, etc.)
  - Active goals list with progress bars
  - Join goal functionality
  - Progress update
  - Empty state
  - Loading state
Missing Features: Member management, goal completion rewards, notifications
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 2.8 Player Profile

```
Screen Name:    Player Profile (shared Profile Page)
File Path:      lib/core/widgets/profile_page.dart
User Role:      All roles (shared)
Navigation Route: Profile tab (last tab in all shells)
Purpose:        User profile management and settings
Current UI Status: ✅ Fully implemented (508 lines)
Data Source:    Firebase Auth, Firestore (users collection)
Firebase Collections Used: users
Providers Used: authStateProvider, userProfileProvider, authServiceProvider
Services Used:  AuthService.updateProfile(), AuthService.uploadProfilePhoto(), AuthService.signOut()
Implemented Features:
  - Profile header with gradient background, avatar (with camera overlay), name, email, role badge, city
  - Account section: Edit Profile, Notifications (coming soon), Privacy & Security (coming soon)
  - Preferences section: Dark/Light mode toggle (persisted via SharedPreferences)
  - Support section: Help Center dialog, Contact Us dialog, About dialog
  - Other section: Terms of Service (coming soon), Privacy Policy (coming soon), Delete Account (confirmation)
  - Sign Out button with auth state cleanup
  - Edit Profile bottom sheet: name, phone, city, bio with validation and save
  - Photo upload capability
Missing Features:
  - ❌ Notifications settings (shows SnackBar)
  - ❌ Privacy & Security settings (shows SnackBar)
  - ❌ Terms of Service content (shows SnackBar)
  - ❌ Privacy Policy content (shows SnackBar)
  - ⚠️ Delete Account (shows dialog but no Firebase user deletion)
Hardcoded/Dummy Data: None
Known Bugs: Delete Account only shows confirmation, doesn't actually delete
Production Readiness: ⚠️ Core profile editing works, other sections are stubs
```

---

## 3. Coach Portal

---

### 3.1 Coach Shell

```
Screen Name:    Coach Shell (Navigation Container)
File Path:      lib/features/home/presentation/coach_shell.dart
User Role:      Coach
Navigation Route: /home (when role == coach)
Purpose:        Role-specific navigation shell with 8 bottom tabs
Current UI Status: ✅ Fully implemented
Data Source:    UserModel
Firebase Collections Used: None (navigation only)
Providers Used: authStateProvider, userProfileProvider
Services Used:  AuthService
Implemented Features:
  - 8-tab bottom navigation: Dashboard, Schedule, Students, Earnings, Jobs, Community, Chat, Profile
  - Uses PremiumShell (responsive layout)
Missing Features: Badge counts on tabs
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 3.2 Coach Dashboard

```
Screen Name:    Coach Dashboard
File Path:      lib/features/coach/presentation/coach_dashboard.dart
User Role:      Coach
Navigation Route: Dashboard tab (index 0 in CoachShell)
Purpose:        Main coach hub with stats, sessions, milestones, subscription
Current UI Status: ✅ Fully implemented (985 lines)
Data Source:    Firestore (coaches, sessions, coachMilestones collections)
Firebase Collections Used: coaches, sessions, coachMilestones
Providers Used: authStateProvider, coachProvider, coachStatsProvider, coachSessionsProvider,
                coachMilestonesProvider, coachMonthlyEarningsProvider, playerProvider
Services Used:  CoachService (getCoach, getCoachStats, getCoachSessions, getCoachMilestones,
                addMilestone, completeMilestone, deleteMilestone)
Implemented Features:
  - Gradient header with avatar, name, specialization, rating badge, subscription tier, hourly rate
  - Stats section (4 cards): Total Sessions, Students, Monthly Earnings, Rating
  - Upcoming Sessions list with session cards (sport icon, student name, time, join button)
  - Session action bottom sheet: Start Video (coming soon), Send Message, Reschedule (coming soon), Cancel
  - Career Progress / Milestones section with CRUD:
    - Add milestone dialog
    - Toggle completion (tap circle)
    - Delete milestone
  - Subscription card: tier display, pricing, expiry, "Manage Plan" button
  - Subscription management bottom sheet: Starter (₹0), Professional (₹499), Premium (₹999)
  - Quick Actions: Messages, Academy Jobs (coming soon), Video Tips, Reports (coming soon)
Missing Features:
  - ❌ Video session (shows "coming soon")
  - ❌ Reschedule session (shows "coming soon")
  - ❌ Reports (shows "coming soon")
  - ❌ Academy Jobs quick action (shows "coming soon")
  - ❌ Subscription payment integration (UI only)
Hardcoded/Dummy Data: Subscription prices hardcoded (₹499, ₹999), plan features are static text
Known Bugs: None
Production Readiness: ⚠️ Core features work, payment and video are stubs
```

### 3.3 Schedule Tab

```
Screen Name:    Schedule Tab
File Path:      lib/features/home/presentation/schedule_tab.dart
User Role:      Coach
Navigation Route: Schedule tab (index 1 in CoachShell)
Purpose:        View all coaching sessions in chronological order
Current UI Status: ✅ Fully implemented (267 lines)
Data Source:    Firestore (sessions collection)
Firebase Collections Used: sessions
Providers Used: coachSessionsProvider, playerProvider
Services Used:  CoachService (getCoachSessions)
Implemented Features:
  - Session list sorted by dateTime ascending
  - Session cards with: date badge (day+month), sport name, player name, time, status
  - Status badges: Upcoming, Completed, Cancelled, Missed (color-coded)
  - Today highlight (primary border)
  - Player name resolution from playerProvider
  - Empty state "No sessions scheduled"
  - Loading state
  - Error state with retry message
Missing Features: Session filtering, calendar view, accept/reject incoming bookings
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 3.4 Students Tab

```
Screen Name:    Students Tab
File Path:      lib/features/home/presentation/students_tab.dart
User Role:      Coach
Navigation Route: Students tab (index 2 in CoachShell)
Purpose:        View roster of assigned students
Current UI Status: ✅ Fully implemented (190 lines)
Data Source:    Firestore (sessions collection, filtered by coachId)
Firebase Collections Used: sessions
Providers Used: coachPlayersProvider, playerProvider
Services Used:  CoachService (getCoachSessions)
Implemented Features:
  - Student list extracted from sessions
  - Student cards with name, sport, session count
  - Player name resolution
  - Empty state "No students yet"
  - Loading state
Missing Features: Student profile drill-down, attendance tracking, student metrics
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 3.5 Earnings Tab

```
Screen Name:    Earnings Tab
File Path:      lib/features/home/presentation/earnings_tab.dart
User Role:      Coach
Navigation Route: Earnings tab (index 3 in CoachShell)
Purpose:        Track coaching earnings and financial metrics
Current UI Status: ✅ Fully implemented (266 lines)
Data Source:    Firestore (sessions, coachMilestones collections)
Firebase Collections Used: sessions, coachMilestones
Providers Used: coachSessionsProvider, coachStatsProvider, coachMonthlyEarningsProvider
Services Used:  CoachService (getCoachSessions, getCoachStats, getCoachMonthlyEarnings)
Implemented Features:
  - Total earnings display
  - Monthly earnings breakdown
  - Session count vs earnings correlation
  - Monthly earnings chart/visualization
  - Empty state
Missing Features: Withdrawal functionality, payment history, tax reports, invoice generation
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Display works, no payment withdrawal
```

### 3.6 Coach Academy Jobs

```
Screen Name:    Coach Academy Jobs Screen
File Path:      lib/features/home/presentation/coach_academy_jobs_screen.dart
User Role:      Coach
Navigation Route: Jobs tab (index 4 in CoachShell)
Purpose:        Browse and apply for academy job postings
Current UI Status: ✅ Fully implemented (311 lines)
Data Source:    Firestore (coachJobs, jobApplications collections)
Firebase Collections Used: coachJobs, jobApplications
Providers Used: coachJobsProvider, coachApplicationsProvider
Services Used:  AcademyService.getJobs(), AcademyService.applyForJob()
Implemented Features:
  - Job listings from all academies
  - Job cards with: title, sport, location, salary range, experience required
  - Apply for job functionality
  - Application tracking (applied/pending status)
  - Empty state
  - Loading state
Missing Features: Job detail view, saved jobs, application withdrawal, notifications
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 3.7 Create Session

```
Screen Name:    Create Session Screen
File Path:      lib/features/coach/presentation/create_session_screen.dart
User Role:      Coach
Navigation Route: /create-session (pushed from coach dashboard)
Purpose:        Create a new coaching session
Current UI Status: ✅ Fully implemented (270 lines)
Data Source:    User input → Firestore (sessions collection)
Firebase Collections Used: sessions
Providers Used: authStateProvider, coachServiceProvider
Services Used:  CoachService.createSession()
Implemented Features:
  - Form with: title, sport, description, date picker, time picker, capacity, price, venue, online toggle
  - Form validation (all required fields)
  - Date picker (next 90 days)
  - Time picker
  - Save to Firestore with coachId
  - Loading state during creation
  - Navigation back on success
Missing Features: Recurring sessions, template sessions, sport-specific fields
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

---

## 4. Academy Portal

---

### 4.1 Academy Shell

```
Screen Name:    Academy Shell (Navigation Container)
File Path:      lib/features/home/presentation/academy_shell.dart
User Role:      Academy
Navigation Route: /home (when role == academy)
Purpose:        Role-specific navigation shell with 7 bottom tabs
Current UI Status: ✅ Fully implemented
Data Source:    UserModel
Firebase Collections Used: None (navigation only)
Providers Used: authStateProvider, userProfileProvider
Services Used:  AuthService
Implemented Features:
  - 7-tab bottom navigation: Dashboard, Batches, Coaches, Advertising, Jobs, Chat, Profile
  - Uses PremiumShell (responsive layout)
Missing Features: Badge counts
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 4.2 Academy Dashboard

```
Screen Name:    Academy Dashboard
File Path:      lib/features/academy/presentation/academy_dashboard.dart
User Role:      Academy
Navigation Route: Dashboard tab (index 0 in AcademyShell)
Purpose:        Academy management hub with stats, batches, advertising, placements
Current UI Status: ✅ Fully implemented (687 lines)
Data Source:    Firestore (academies, batches, academyPlacements, campaigns collections)
Firebase Collections Used: academies, batches, academyPlacements, campaigns
Providers Used: academyProvider, activeCoachesCountProvider, academyPlacementsProvider, academyServiceProvider
Services Used:  AcademyService (getAcademy, getBatches, getPlacements, getCampaigns, createCampaign)
Implemented Features:
  - Gradient header with logo, name, verification badge, stats (students, coaches, reputation, placements)
  - Batch management with StreamBuilder (list, create)
  - Advertising suite with campaign creation dialog
  - Coach placements list
  - Stats cards
Missing Features: Batch detail view, student enrollment, coach invitation flow, detailed analytics
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Core dashboard works, sub-flows incomplete
```

### 4.3 Batches Tab

```
Screen Name:    Batches Tab
File Path:      lib/features/home/presentation/batches_tab.dart
User Role:      Academy
Navigation Route: Batches tab (index 1 in AcademyShell)
Purpose:        Manage academy training batches
Current UI Status: ✅ Fully implemented (394 lines)
Data Source:    Firestore (batches collection)
Firebase Collections Used: batches
Providers Used: academyBatchesProvider
Services Used:  AcademyService.getBatches(), AcademyService.createBatch(), AcademyService.deleteBatch()
Implemented Features:
  - Batch list with name, sport, capacity, schedule
  - Create batch dialog (name, sport, capacity, schedule)
  - Delete batch (soft delete)
  - Empty state
  - Loading state
Missing Features: Batch detail view, student enrollment in batch, coach assignment to batch, attendance
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ CRUD works, no enrollment or detail view
```

### 4.4 Academy Coaches Tab

```
Screen Name:    Academy Coaches Tab
File Path:      lib/features/home/presentation/academy_coaches_tab.dart
User Role:      Academy
Navigation Route: Coaches tab (index 2 in AcademyShell)
Purpose:        Manage academy-affiliated coaches
Current UI Status: ✅ Fully implemented (363 lines)
Data Source:    Firestore (academyPlacements, coachInvitations collections)
Firebase Collections Used: academyPlacements, coachInvitations
Providers Used: academyCoachesProvider, academyInvitationsProvider, activeCoachesCountProvider
Services Used:  AcademyService.getPlacements(), AcademyService.inviteCoach(), AcademyService.sendCoachInvitation()
Implemented Features:
  - Active coaches list from placements
  - Invite coach by email
  - Invitation tracking (pending/accepted)
  - Coach count display
  - Empty state
Missing Features: Coach profile detail, remove coach, batch assignment, ratings
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Core management works, detailed flows missing
```

### 4.5 Advertising Tab

```
Screen Name:    Advertising Tab
File Path:      lib/features/home/presentation/advertising_tab.dart
User Role:      Academy
Navigation Route: Advertising tab (index 3 in AcademyShell)
Purpose:        Create and manage advertising campaigns
Current UI Status: ✅ Fully implemented (320 lines)
Data Source:    Firestore (campaigns collection)
Firebase Collections Used: campaigns
Providers Used: academyCampaignsProvider
Services Used:  AcademyService.getCampaigns(), AcademyService.createCampaign()
Implemented Features:
  - Campaign list display
  - Create campaign dialog (name, budget, type)
  - Campaign status tracking
  - Empty state
Missing Features: Campaign analytics, budget tracking, reach metrics, campaign editing
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Basic CRUD works, no analytics
```

### 4.6 Academy Jobs Tab

```
Screen Name:    Academy Jobs Tab
File Path:      lib/features/home/presentation/academy_jobs_tab.dart
User Role:      Academy
Navigation Route: Jobs tab (index 4 in AcademyShell)
Purpose:        Post and manage academy job listings
Current UI Status: ✅ Fully implemented (367 lines)
Data Source:    Firestore (coachJobs, jobApplications collections)
Firebase Collections Used: coachJobs, jobApplications
Providers Used: academyJobsProvider
Services Used:  AcademyService.postJob(), AcademyService.getAcademyJobs(), AcademyService.getJobApplications()
Implemented Features:
  - Job posting form (title, sport, location, salary, experience, description, perks)
  - Job listings for the academy
  - View applications per job
  - Empty state
Missing Features: Application review/accept/reject, candidate profiles, interview scheduling
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Posting works, review flow missing
```

---

## 5. Parent Portal

---

### 5.1 Parent Shell

```
Screen Name:    Parent Shell (Navigation Container)
File Path:      lib/features/home/presentation/parent_shell.dart
User Role:      Parent
Navigation Route: /home (when role == parent)
Purpose:        Role-specific navigation shell with 5 bottom tabs
Current UI Status: ✅ Fully implemented
Data Source:    UserModel
Firebase Collections Used: None (navigation only)
Providers Used: authStateProvider, userProfileProvider
Services Used:  AuthService
Implemented Features:
  - 5-tab bottom navigation: Dashboard, Coaches, Progress, Chat, Profile
  - Uses PremiumShell (responsive layout)
Missing Features: Badge counts, child selector
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 5.2 Parent Dashboard

```
Screen Name:    Parent Dashboard
File Path:      lib/features/home/presentation/parent_dashboard.dart
User Role:      Parent
Navigation Route: Dashboard tab (index 0 in ParentShell)
Purpose:        Overview of all linked children's sports activities
Current UI Status: ✅ Fully implemented (451 lines)
Data Source:    Firestore (players collection filtered by parentId)
Firebase Collections Used: players, playerMetrics
Providers Used: parentPlayersProvider, authStateProvider
Services Used:  PlayerService.getParentPlayers(), PlayerService.logMetric()
Implemented Features:
  - Multi-player overview (all children linked to parent)
  - Child cards with name, age, sports, level, points
  - Quick stats per child (sessions, points, rank)
  - Log metric for child (bottom sheet)
  - Add new player form (name, age, sports)
  - Empty state for no children
  - Loading state
Missing Features: Child switching, detailed child view, session booking for child, progress comparison
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 5.3 Parent Progress Screen

```
Screen Name:    Parent Progress Screen
File Path:      lib/features/home/presentation/parent_progress_screen.dart
User Role:      Parent
Navigation Route: Progress tab (index 2 in ParentShell)
Purpose:        Track child's athletic progress and metrics
Current UI Status: ✅ Fully implemented (223 lines)
Data Source:    Firestore (players, playerMetrics collections)
Firebase Collections Used: players, playerMetrics
Providers Used: parentPlayersProvider, playerMetricsProvider
Services Used:  PlayerService.getParentPlayers()
Implemented Features:
  - Child selector (if multiple children)
  - Progress overview per child
  - Performance metrics display
  - Level and rank progress
  - Recent activity
Missing Features: Detailed charts, comparison between periods, coach feedback integration
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

---

## 6. Admin Portal

---

### 6.1 Admin Shell

```
Screen Name:    Admin Shell (Navigation Container)
File Path:      lib/features/home/presentation/admin_shell.dart
User Role:      Admin
Navigation Route: /home (when role == admin)
Purpose:        Role-specific navigation shell with 5 bottom tabs
Current UI Status: ✅ Fully implemented
Data Source:    UserModel
Firebase Collections Used: None (navigation only)
Providers Used: authStateProvider, userProfileProvider
Services Used:  AuthService
Implemented Features:
  - 5-tab bottom navigation: Dashboard, Venues, Users, Coupons, Profile
  - Uses PremiumShell (responsive layout)
Missing Features: Badge counts
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 6.2 Admin Dashboard

```
Screen Name:    Admin Dashboard
File Path:      lib/features/admin/presentation/admin_dashboard.dart
User Role:      Admin
Navigation Route: Dashboard tab (index 0 in AdminShell)
Purpose:        Platform management and oversight
Current UI Status: ✅ Fully implemented (603 lines)
Data Source:    Firestore (users, venues, contracts, adminTasks, coupons collections)
Firebase Collections Used: users, venues, contracts, adminTasks, coupons
Providers Used: allUsersProvider, venuesStreamProvider, totalRevenueProvider,
                activeUsersCountProvider, adminTasksProvider, couponsProvider
Services Used:  AuthService.getUsers(), AuthService.getAdminTasks(), AuthService.addAdminTask(),
                VenueService.getVenues(), ContractService.getTotalRevenueStream()
Implemented Features:
  - Stats overview: Total Users, Venues, Revenue, Active Users
  - Task Master: create, view, toggle status of admin tasks with priority badges
  - Manual venue addition form (name, address, city, sports, amenities, price, coordinates)
  - Coupon management: list existing, create new coupon (code, discount, eligibility)
  - Revenue tracking from contract fees
  - User count streaming
Missing Features: Analytics dashboard, user management actions (ban/delete), venue verification workflow, push notification management
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Core management works, advanced admin features missing
```

### 6.3 Users Tab

```
Screen Name:    Users Tab
File Path:      lib/features/home/presentation/users_tab.dart
User Role:      Admin
Navigation Route: Users tab (index 2 in AdminShell)
Purpose:        View and manage platform users
Current UI Status: ✅ Fully implemented (171 lines)
Data Source:    Firestore (users collection)
Firebase Collections Used: users
Providers Used: allUsersProvider
Services Used:  AuthService.getUsers()
Implemented Features:
  - User list with name, email, role, status
  - Search/filter users
  - User count display
  - Empty state
Missing Features: User detail view, ban/disable user, role change, activity log
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Display works, no management actions
```

### 6.4 Coupons Tab

```
Screen Name:    Coupons Tab
File Path:      lib/features/home/presentation/coupons_tab.dart
User Role:      Admin
Navigation Route: Coupons tab (index 3 in AdminShell)
Purpose:        Create and manage promotional coupons
Current UI Status: ✅ Fully implemented (319 lines)
Data Source:    Firestore (coupons collection)
Firebase Collections Used: coupons
Providers Used: couponsProvider
Services Used:  AuthService.getCoupons(), AuthService.addCoupon(), AuthService.toggleCouponStatus()
Implemented Features:
  - Coupon list with code, discount %, eligibility, active status
  - Create coupon dialog (code, discount percentage, eligibility criteria)
  - Toggle coupon active/inactive
  - Empty state
Missing Features: Coupon usage analytics, expiry dates, max usage limits, bulk creation
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

---

## 7. Common Features

---

### 7.1 Chat List

```
Screen Name:    Chat List Screen
File Path:      lib/features/chat/presentation/chat_list_screen.dart
User Role:      All (Player, Coach, Academy, Parent, Admin)
Navigation Route: Chat tab (varies by shell)
Purpose:        View and manage all conversations
Current UI Status: ✅ Fully implemented (428 lines)
Data Source:    Firestore (chats collection, users collection)
Firebase Collections Used: chats, users
Providers Used: userChatsProvider, allUsersProvider, authStateProvider
Services Used:  ChatService.getUserChats(), ChatService.createChat()
Implemented Features:
  - Chat list sorted by lastMessageTime
  - Chat tiles with: other user name, last message preview, unread count, timestamp
  - Search/filter conversations by name or message content
  - New conversation FAB → user picker bottom sheet
  - Create new chat with any user
  - User lookup from allUsersProvider
  - Empty state "No conversations yet"
  - Loading state
  - Error state
Missing Features: Online status, typing indicators, message previews in list, pin/mute chats
Hardcoded/Dummy Data: "Online" status is hardcoded in chat detail, not real
Known Bugs: None
Production Readiness: ✅ Ready
```

### 7.2 Chat Detail

```
Screen Name:    Chat Detail Screen
File Path:      lib/features/chat/presentation/chat_detail_screen.dart
User Role:      All
Navigation Route: /chat/:chatId (chatId from path, otherUserId from extra)
Purpose:        Real-time messaging between two users
Current UI Status: ✅ Fully implemented (322 lines)
Data Source:    Firestore (chats/{id}/messages subcollection)
Firebase Collections Used: chats, chats/{id}/messages
Providers Used: chatMessagesProvider, userChatsProvider, userProfileProvider, authStateProvider
Services Used:  ChatService.sendMessage(), ChatService.getChatMessages()
Implemented Features:
  - Real-time message list (ordered by createdAt ascending)
  - Send text messages via TextField + send button
  - Message bubbles: sent (primary color, right-aligned) vs received (card color, left-aligned)
  - Timestamp display per message
  - Auto-scroll to bottom on new message
  - Other user name and initials avatar in AppBar
  - "Online" status indicator (hardcoded)
  - Empty state "No messages yet"
  - Loading state
  - Error state
Missing Features:
  - ❌ Phone call button (shows "coming soon")
  - ❌ More options menu (shows "coming soon")
  - ❌ File attachment (shows "coming soon")
  - ❌ Image messages (MessageType.image exists in model but not handled in UI)
  - ❌ Read receipts / delivery status
  - ❌ Typing indicators
  - ❌ Push notifications for new messages
Hardcoded/Dummy Data: "Online" status is always shown regardless of actual presence
Known Bugs: None
Production Readiness: ⚠️ Core messaging works, multimedia and presence missing
```

### 7.3 Contract List

```
Screen Name:    Contract List Screen
File Path:      lib/features/contracts/presentation/contract_list_screen.dart
User Role:      All (authenticated)
Navigation Route: /contracts
Purpose:        View and filter all user contracts
Current UI Status: ✅ Fully implemented (302 lines)
Data Source:    Firestore (contracts collection)
Firebase Collections Used: contracts
Providers Used: userContractsProvider, authStateProvider
Services Used:  ContractService.getUserContracts()
Implemented Features:
  - Contract list filtered by current user (partyAId or partyBId)
  - Filter chips: All, Active, Pending, Completed, Disputed
  - Contract cards with: type icon, party roles, amount (₹), status badge, escrow status, signature status
  - Color-coded status badges (draft=dim, pending=warning, active=success, etc.)
  - Auth-gated content (shows "Sign in" if not authenticated)
  - Empty state per filter
  - Loading state
  - Error state with retry
Missing Features: Create contract flow, contract negotiation, export PDF
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 7.4 Contract Detail

```
Screen Name:    Contract Detail Screen
File Path:      lib/features/contracts/presentation/contract_detail_screen.dart
User Role:      All (contract parties)
Navigation Route: /contracts/:contractId
Purpose:        View complete contract details
Current UI Status: ✅ Fully implemented (476 lines)
Data Source:    Firestore (contracts collection)
Firebase Collections Used: contracts
Providers Used: contractProvider
Services Used:  ContractService.getContract()
Implemented Features:
  - Contract header: type, ID display, status badge
  - Party Information: Party A and B cards with role, name, signed status
  - Financial Breakdown: Session Fee, Platform Fee (10%), Opportunity Fee (10%), Contract Savings (10%), Total Amount
  - Escrow Status card with progress bar and release date
  - Digital Signatures section: signed/unsigned with timestamps
  - Terms & Conditions text
  - "Download PDF" button (stub)
  - "Raise Dispute" button (stub)
Missing Features:
  - ❌ Download PDF (button exists, no implementation)
  - ❌ Raise Dispute (button exists, no implementation)
  - ❌ Sign contract flow (signature stored but no signing UI)
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Display is complete, actions are stubs
```

### 7.5 Venue Discovery

```
Screen Name:    Venue Discovery Screen
File Path:      lib/features/venue/presentation/venue_discovery_screen.dart
User Role:      All (Player, Parent, Admin)
Navigation Route: /venues
Purpose:        Search and browse sports venues
Current UI Status: ✅ Fully implemented (356 lines)
Data Source:    Firestore (venues collection)
Firebase Collections Used: venues
Providers Used: venuesStreamProvider
Services Used:  VenueService.getVenues()
Implemented Features:
  - Venue list with cards: name, sport icons, location, rating, price/hr, Google Listed badge
  - Search bar with debounce (300ms)
  - Sport filter chips: All, Cricket, Football, Badminton, Tennis, Swimming, Basketball
  - Responsive layout: mobile (list), tablet (2-column), desktop (3-column)
  - Venue card with amenities preview (compact mode)
  - Empty state "No venues found"
  - Loading state
  - Error state with retry
Missing Features:
  - ❌ Map view (google_maps_flutter declared but not integrated)
  - ❌ Booking flow
  - ❌ Reviews/ratings
  - ❌ Location-based sorting
Hardcoded/Dummy Data: None
Known Bugs: Client-side search only
Production Readiness: ⚠️ Discovery works, booking and map missing
```

### 7.6 Venue Detail

```
Screen Name:    Venue Detail Screen
File Path:      lib/features/venue/presentation/venue_detail_screen.dart
User Role:      All
Navigation Route: /venues/:venueId
Purpose:        View complete venue information
Current UI Status: ✅ Fully implemented (348 lines)
Data Source:    Firestore (venues collection)
Firebase Collections Used: venues
Providers Used: venueProvider
Services Used:  VenueService.getVenue()
Implemented Features:
  - Gradient header with venue name, location, sport types
  - Info chips: rating, city, capacity, price/hr
  - About section (description)
  - Amenities grid with check icons
  - Available Time Slots section (6 hardcoded slots)
  - "Book Now" button
  - Loading/error states
Missing Features:
  - ❌ Real time slot data (hardcoded 6 slots with fixed prices/availability)
  - ❌ Actual booking flow (button has empty onPressed)
  - ❌ Photo gallery
  - ❌ Reviews section
  - ❌ Map integration
Hardcoded/Dummy Data:
  - Time slots are hardcoded: ['6:00 - 7:00 AM', '7:00 - 8:00 AM', etc.]
  - Prices hardcoded: [500, 500, 600, 600, 700, 700]
  - Availability hardcoded: [true, true, false, true, true, false]
Known Bugs: Book Now button does nothing (onPressed: () {})
Production Readiness: ⚠️ Display works, booking is non-functional
```

### 7.7 Video Analysis Service

```
Screen Name:    Video Analysis Service
File Path:      lib/features/video_analysis/data/video_analysis_service.dart
User Role:      Player
Purpose:        Firebase Storage + Firestore service for video management
Current UI Status: ✅ Fully implemented
Data Source:    Firebase Storage, Firestore (videoAnalysis collection)
Firebase Collections Used: videoAnalysis
Providers Used: videoAnalysisServiceProvider, playerVideosProvider, latestVideoProvider
Services Used:  VideoAnalysisService (upload, list, delete, getLatest)
Implemented Features:
  - Upload video to Firebase Storage (/videos/{playerId}/{videoId})
  - Save metadata to Firestore
  - List player's videos
  - Get latest video
  - Delete video from Storage and Firestore
Missing Features: Actual AI analysis processing, analysis results storage
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ⚠️ Storage/CRUD works, no AI analysis
```

### 7.8 Squad Goals Service

```
Screen Name:    Squad Goals Service
File Path:      lib/features/squad_goals/data/squad_goals_service.dart
User Role:      Player
Purpose:        Firestore service for squad goals CRUD
Current UI Status: ✅ Fully implemented
Data Source:    Firestore (squadGoals collection)
Firebase Collections Used: squadGoals
Providers Used: squadGoalsServiceProvider, activeSquadGoalsBySportProvider, playerSquadGoalsProvider
Services Used:  SquadGoalsService (CRUD, join, updateProgress)
Implemented Features:
  - Create squad goal
  - Get active goals by sport
  - Get player's squad goals
  - Join goal
  - Update progress
  - Delete goal
Missing Features: Goal completion logic, reward distribution, notifications
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

### 7.9 Notifications

```
Screen Name:    Notifications
File Path:      None (not implemented)
User Role:      All
Navigation Route: None
Purpose:        Push notifications and in-app notifications
Current UI Status: ❌ Missing
Data Source:    N/A
Firebase Collections Used: notifications (firestore rules exist, no service/screen)
Providers Used: None
Services Used:  None
Implemented Features: None
Missing Features:
  - ❌ Push notification service (firebase_messaging declared but not configured)
  - ❌ Local notifications (flutter_local_notifications declared but not used)
  - ❌ Notification permission handling
  - ❌ FCM token management
  - ❌ Notification display/handling
  - ❌ In-app notification center
  - ❌ Notification preferences
Hardcoded/Dummy Data: N/A
Known Bugs: N/A
Production Readiness: ❌ Not implemented
```

---

## 8. Role Router

```
Screen Name:    Role Router
File Path:      lib/features/home/presentation/role_router.dart
User Role:      All
Navigation Route: /home
Purpose:        Reads user auth state and profile, dispatches to correct role shell
Current UI Status: ✅ Fully implemented (104 lines)
Data Source:    Firebase Auth, Firestore (users collection)
Firebase Collections Used: users
Providers Used: authStateProvider, userProfileProvider
Services Used:  AuthService.getUserProfile()
Implemented Features:
  - Auth state check → if null, shows error
  - User profile fetch from Firestore
  - Role-based dispatch:
    - parent → ParentShell
    - player → PlayerShell
    - coach → CoachShell
    - academy → AcademyShell
    - admin → AdminShell
  - Loading state during profile fetch
  - Error state for missing profile
Missing Features: None
Hardcoded/Dummy Data: None
Known Bugs: None
Production Readiness: ✅ Ready
```

---

## 9. Layout System

### 9.1 PremiumShell

```
Screen Name:    PremiumShell (Master Layout)
File Path:      lib/design_system/layouts/premium_shell.dart
Purpose:        Responsive navigation shell for all roles
Current UI Status: ✅ Fully implemented (566 lines)
Responsive Breakpoints:
  - Mobile (< 600px):  AppBar + Bottom Nav + Slide-out Drawer
  - Tablet (600-1023px): Collapsed 80px sidebar (icon-only) + Top Bar
  - Desktop (>= 1024px): Full 260px sidebar + Top Bar
Implemented Features:
  - IndexedStack for screen persistence
  - Mobile: hamburger menu → slide-out drawer with sections
  - Desktop: PremiumSidebar with header (logo, user info), nav tiles with accent bar, footer (settings, theme toggle, sign out)
  - Tablet: PremiumCollapsedSidebar with tooltips
  - Theme toggle (dark/light) via themeModeProvider
  - Sign out via authServiceProvider
  - PopScope for back navigation handling
Missing Features: Notification badge on sidebar, settings screen
```

### 9.2 Supporting Layout Components

| Component | File | Purpose |
|-----------|------|---------|
| PremiumSidebar | premium_sidebar.dart (325 lines) | Full sidebar with hover states, accent bar, badges |
| PremiumCollapsedSidebar | premium_sidebar.dart | Icon-only sidebar with tooltips |
| PremiumDrawer | premium_drawer.dart (197 lines) | Slide-in drawer with sections |
| PremiumTopBar | premium_top_bar.dart (152 lines) | 72px top bar with search, notifications, avatar |
| AppBottomNav | bottom_nav.dart (147 lines) | 60px bottom nav with animated indicator |
| PremiumNavItem | premium_nav_item.dart (17 lines) | Navigation item data class |
| SidebarTile | sidebar.dart (170 lines) | Basic sidebar tile (legacy) |
| DesktopSidebar | sidebar.dart | Simpler desktop sidebar (legacy) |
| AppNavRail | nav_rail.dart (74 lines) | Material NavigationRail wrapper |

---

## Master Feature Status Table

| Feature | UI | Backend | Database | Testing | Overall Status |
|---------|-----|---------|----------|---------|----------------|
| **Auth: Splash** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Auth: Login** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Auth: Signup** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Auth: Forgot Password** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Auth: Google Sign-In** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Auth: Phone OTP** | ❌ | ❌ | ❌ | ❌ | ❌ Missing |
| **Player: Dashboard** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Player: Performance** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Player: Video Analysis** | ✅ | ⚠️ | ✅ | ❌ | ⚠️ Partial |
| **Player: Squad Goals** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Coach: Dashboard** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Coach: Schedule** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Coach: Students** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Coach: Earnings** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Coach: Create Session** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Coach: Milestones** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Coach: Subscription** | ✅ | ⚠️ | ⚠️ | ❌ | ⚠️ Partial |
| **Academy: Dashboard** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Academy: Batches** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Academy: Coaches** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Academy: Advertising** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Academy: Jobs** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Parent: Dashboard** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Parent: Progress** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Admin: Dashboard** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Admin: Users** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Admin: Coupons** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Chat: List** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Chat: Detail** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Contracts: List** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Contracts: Detail** | ✅ | ⚠️ | ✅ | ❌ | ⚠️ Partial |
| **Community: Feed** | ✅ | ⚠️ | ✅ | ❌ | ⚠️ Partial |
| **Venue: Discovery** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Venue: Detail** | ✅ | ⚠️ | ✅ | ❌ | ⚠️ Partial |
| **Venue: Map View** | ❌ | ❌ | ❌ | ❌ | ❌ Missing |
| **Venue: Booking** | ❌ | ❌ | ❌ | ❌ | ❌ Missing |
| **Notifications** | ❌ | ❌ | ❌ | ❌ | ❌ Missing |
| **Session Booking (Player)** | ❌ | ❌ | ❌ | ❌ | ❌ Missing |
| **Session Accept/Reject** | ❌ | ❌ | ❌ | ❌ | ❌ Missing |
| **Availability Calendar** | ❌ | ❌ | ❌ | ❌ | ❌ Missing |
| **Profile: Edit** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Profile: Photo Upload** | ✅ | ✅ | ✅ | ❌ | ⚠️ Partial |
| **Profile: Delete Account** | ⚠️ | ❌ | ❌ | ❌ | ❌ Missing |
| **Any Screen: Unit Tests** | — | — | — | ❌ | ❌ Missing |
| **Any Screen: Widget Tests** | — | — | — | ❌ | ❌ Missing |
| **Any Screen: Integration Tests** | — | — | — | ❌ | ❌ Missing |

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| **Total screens/tabs analyzed** | 35 |
| **Fully implemented (UI + Backend + DB)** | 22 |
| **Partially implemented (UI works, backend stubs)** | 10 |
| **Missing entirely** | 3 (Notifications, Venue Map, Venue Booking) |
| **Total feature modules** | 13 |
| **Total .dart files in features/** | ~55 |
| **Total lines of feature code** | ~12,000+ |
| **Tests written** | 0 |
| **Firestore collections used** | 18+ |
| **Riverpod providers defined** | ~35 |
| **Hardcoded data instances** | 6 (venue time slots, subscription prices, community roles, daily missions, AI tips, motivational quotes) |

---

## Critical Missing Flows

| Flow | Impact | Complexity |
|------|--------|------------|
| Session Booking (Player → Coach) | HIGH - Core marketplace function | Medium |
| Session Accept/Reject (Coach) | HIGH - Required for booking loop | Low |
| Venue Booking | HIGH - Revenue stream | Medium |
| Payment Integration | HIGH - Escrow model exists, no gateway | High |
| Push Notifications | HIGH - Engagement/retention | Medium |
| Phone OTP Auth | MEDIUM - India market requirement | Low |
| Coach Availability Calendar | MEDIUM - Required for booking | Medium |
| Session Detail Screen | MEDIUM - Drill-down view | Low |
| Coach Profile Detail | MEDIUM - Dedicated view | Low |
| Real AI Video Analysis | LOW - Future phase (V2) | High |

---

*End of SCREEN_FEATURE_MATRIX.md*
