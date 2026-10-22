# Coach Module Audit Report

**Date:** 2026-07-10
**Scope:** Complete end-to-end audit of the Coach module in SportsEco
**Mode:** READ-ONLY — no code changes made
**Auditor:** opencode (automated)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Authentication](#3-authentication)
4. [Dashboard](#4-dashboard)
5. [Sessions](#5-sessions)
6. [Students](#6-students)
7. [Earnings](#7-earnings)
8. [Performance / Metrics](#8-performance--metrics)
9. [Video Analysis](#9-video-analysis)
10. [Academy Jobs](#10-academy-jobs)
11. [Coach Discovery](#11-coach-discovery)
12. [Subscriptions](#12-subscriptions)
13. [Notifications](#13-notifications)
14. [Profile](#14-profile)
15. [Navigation](#15-navigation)
16. [Code Quality](#16-code-quality)
17. [Completion Summary](#17-completion-summary)
18. [Issue Index](#18-issue-index)

---

## 1. Executive Summary

The Coach module provides a role-based shell (`CoachShell`) with 8 tabs: Dashboard, Schedule, Students, Earnings, Jobs, Community, Chat, and Profile. The module is **functional at the surface level** — coaches can sign up, create sessions, view students, browse jobs, and discover other coaches. However, **critical gaps exist** in session lifecycle management (cancel/complete/reschedule are all non-functional), student interaction (no drill-down, no chat, no progress), subscription management (display-only), and notifications (entirely placeholder).

**Overall Module Completion: ~30%**

| Sub-Module | Completion | Status |
|---|---|---|
| Authentication | 90% | Functional |
| Dashboard | 70% | Mostly functional, some placeholders |
| Sessions | 25% | Create/read only, lifecycle broken |
| Students | 15% | Display only |
| Earnings | 30% | Display only, calculations wrong |
| Performance | 10% | No coach-facing view |
| Video Analysis | 0% | Not accessible to coaches |
| Academy Jobs | 70% | Browse + apply functional |
| Coach Discovery | 80% | Browse + book functional |
| Subscriptions | 20% | Display only |
| Notifications | 5% | All placeholders |
| Profile | 40% | Edit partially works |
| Navigation | 70% | Most routes work, 3 broken |

---

## 2. Architecture Overview

### Tech Stack
- **Framework:** Flutter with Riverpod state management
- **Navigation:** GoRouter with role-based shell routing
- **Backend:** Firebase (Firestore, Auth, Storage)
- **Project Root:** `D:\work\code\flutter\projects\Sports_App`

### Coach Shell Structure
```
CoachShell (coach_shell.dart)
├── Tab 0: CoachDashboard (coach_dashboard.dart)
├── Tab 1: ScheduleTab (schedule_tab.dart)
├── Tab 2: StudentsTab (students_tab.dart)
├── Tab 3: EarningsTab (earnings_tab.dart)
├── Tab 4: CoachAcademyJobsScreen (coach_academy_jobs_screen.dart)
├── Tab 5: CommunityScreen
├── Tab 6: ChatListScreen
└── Tab 7: ProfilePage (profile_page.dart) — shared across all roles
```

### Key Service Dependencies
| Service | File | Coach Operations |
|---|---|---|
| `CoachService` | `lib/services/coach_service.dart` | CRUD sessions, stats, milestones, search coaches |
| `PlayerService` | `lib/services/player_service.dart` | Get coach's players, metrics |
| `AuthService` | `lib/services/auth_service.dart` | Login, signup, profile update |
| `AcademyService` | `lib/services/academy_service.dart` | Jobs, applications |
| `ChatService` | `lib/services/chat_service.dart` | Chat CRUD |

### Key Provider Dependencies (from `lib/services/providers.dart`)
- `coachServiceProvider` → `CoachService`
- `coachSessionsProvider(coachId)` → Stream of sessions
- `coachStatsProvider(coachId)` → Future of stats map
- `coachMonthlyEarningsProvider(coachId)` → Future of monthly earnings
- `coachMilestonesProvider(coachId)` → Stream of milestones
- `coachPlayersProvider(coachId)` → Stream of players
- `coachJobsProvider` → Stream of academy job postings
- `coachApplicationsProvider(coachId)` → Stream of job applications

### Firestore Collections Used by Coach Module
| Collection | Operations | Notes |
|---|---|---|
| `users` | Read/Update | Profile data |
| `coaches` | Read/Update | Coach-specific data |
| `sessions` | Create/Read | Two inconsistent write schemas |
| `coachMilestones` | Create/Read/Update/Delete | Career milestones |
| `players` | Read | Student list (queried by `coachId`) |
| `playerMetrics` | Read | Student performance data |
| `jobs` | Read | Academy job postings |
| `jobApplications` | Create/Read | Job applications |

---

## 3. Authentication

### 3.1 Login
- **File:** `lib/features/auth/presentation/login_screen.dart`
- **Status:** FUNCTIONAL
- Email/password login via `AuthService.signIn()` (line 37)
- Google sign-in via `AuthService.signInWithGoogle()` (line 56)
- Form validation: email required + must contain `@`, password min 6 chars
- Error handling: catches exceptions and shows SnackBar
- Loading states: `_isLoading` and `_isGoogleLoading` tracked separately
- After login: navigates to `/home` which routes to role-based shell

### 3.2 Signup (Coach)
- **File:** `lib/features/auth/presentation/signup_screen.dart`
- **Status:** FUNCTIONAL
- 3-step wizard: Role Selection → Personal Info → Credentials
- Coach role available at step 0 (line 177-183)
- Form validation: name required, email regex, phone 10 digits, password min 6 chars
- On signup (line 43-50): calls `AuthService.signUp()` which:
  - Creates `users` doc with role
  - Creates `coaches` doc with initial fields: `coachId`, `name`, `email`, `phone`, `city`, `isSubscribed: false`, `subscriptionTier: 'Starter'`, `rating: 0.0`, `totalReviews: 0`, `isVerified: false`, `experience: 0`, `hourlyRate: 0`

### 3.3 Profile Creation
- **File:** `lib/services/auth_service.dart:60-77`
- **Status:** FUNCTIONAL
- Coach profile auto-created on signup with starter defaults
- No separate profile completion flow exists

### 3.4 Logout
- **File:** `lib/core/widgets/profile_page.dart:76-77`
- **Status:** FUNCTIONAL
- Calls `authServiceProvider.signOut()` then navigates to `/login`

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| A-1 | No email verification flow after signup | Medium | `signup_screen.dart` | 43-50 | Add email verification send + check | 2h |
| A-2 | No onboarding/profile completion after coach signup | Medium | `signup_screen.dart` | 50 | Add guided profile setup wizard | 4h |

---

## 4. Dashboard

### 4.1 Stats Section
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:241-303`
- **Status:** FUNCTIONAL
- Shows 4 stat cards: Total Sessions, Students, Monthly Earnings, Rating
- Data from `coachStatsProvider` (FutureProvider) and `coachMonthlyEarningsProvider` (FutureProvider)
- Error state: shows "Unable to load stats right now." (line 298-299)
- Loading state: `CircularProgressIndicator` (line 295)
- Responsive: wide layout (4 in row) vs mobile (2x2 grid)

### 4.2 Upcoming Sessions
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:305-390`
- **Status:** PARTIALLY FUNCTIONAL
- Shows max 5 sessions sorted by date
- Empty state: shows "Create Session" button → navigates to `/create-session` (line 341)
- Error state: shows cloud-off icon + "Unable to load sessions" (line 378-386)
- Loading state: `CircularProgressIndicator` (line 367)
- Each session card shows: sport icon, student name (fetched via `playerProvider`), time
- "Join" button on each card triggers `_showSessionActions()` bottom sheet

### 4.3 Session Actions (Bottom Sheet)
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:505-551`
- **Status:** MOSTLY BROKEN

| Action | Line | Behavior | Status |
|---|---|---|---|
| Start Video Session | 525-529 | Shows SnackBar "Video session feature coming soon" | DEAD — placeholder |
| Send Message | 531-533 | Navigates to `/chat` | PARTIAL — no chatId or otherUserId passed |
| Reschedule | 535-539 | Shows SnackBar "Rescheduling coming soon" | DEAD — placeholder |
| Cancel Session | 541-546 | Opens confirmation dialog | BROKEN — see 4.4 |

### 4.4 Cancel Session
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:562-586`
- **Status:** BROKEN — UI exists but NO Firestore write
- Confirmation dialog shows "Are you sure you want to cancel this session?"
- "Yes, Cancel" button (line 575-579): only shows SnackBar "Session cancelled"
- **Does NOT update session status in Firestore** — session remains in its original state

### 4.5 Milestones
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:588-754`
- **Status:** FUNCTIONAL
- Add milestone: dialog with text input → calls `CoachService.addMilestone()` → writes to `coachMilestones` collection
- Complete milestone: tap check icon → calls `CoachService.completeMilestone()` → updates `done: true`
- Delete milestone: tap trash icon → calls `CoachService.deleteMilestone()` → deletes doc
- Empty state: "No milestones yet" with "Add Milestone" button
- Error state: cloud-off icon with "Unable to load milestones"

### 4.6 Subscription Card
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:756-913`
- **Status:** DISPLAY ONLY
- Shows plan name, price, expiry date, active/inactive status
- "Manage Plan" button opens bottom sheet with 3 plan options
- **No actual upgrade/downgrade/restore functionality** — plan options are display only (line 876-912)

### 4.7 Quick Actions
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:915-975`
- **Status:** 2/4 FUNCTIONAL

| Action | Line | Target | Status |
|---|---|---|---|
| Messages | 935 | `/chat` | FUNCTIONAL |
| Academy Jobs | 937 | SnackBar placeholder | BROKEN — should navigate to Jobs tab |
| Video Tips | 943 | `/video-analysis` | BROKEN — route not registered |
| Reports | 945 | SnackBar placeholder | DEAD — placeholder |

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| D-1 | Cancel session does not update Firestore | Critical | `coach_dashboard.dart` | 575-579 | Add `updateSessionStatus(sessionId, 'cancelled')` call | 1h |
| D-2 | "Start Video Session" is placeholder snackbar | Medium | `coach_dashboard.dart` | 525-529 | Implement video session launch or remove | 2h |
| D-3 | "Reschedule" is placeholder snackbar | Medium | `coach_dashboard.dart` | 535-539 | Implement reschedule flow with date picker + Firestore update | 4h |
| D-4 | "Send Message" navigates to `/chat` without chatId | Medium | `coach_dashboard.dart` | 531-533 | Find or create chat session, pass chatId + otherUserId | 2h |
| D-5 | "Academy Jobs" quick action is placeholder snackbar | Medium | `coach_dashboard.dart` | 937 | Navigate to Jobs tab index or `/coach-academy-jobs` route | 0.5h |
| D-6 | "Video Tips" navigates to unregistered `/video-analysis` route | High | `coach_dashboard.dart` | 943 | Register route in `app_router.dart` or remove button | 0.5h |
| D-7 | "Reports" is placeholder snackbar | Low | `coach_dashboard.dart` | 945 | Implement reports feature or remove | 4h |
| D-8 | Subscription manage plan has no actual upgrade logic | High | `coach_dashboard.dart` | 841-912 | Implement Stripe/payment integration + Firestore tier update | 8h+ |
| D-9 | No session edit capability | Medium | — | — | Create edit session screen + service method | 4h |
| D-10 | "Join" button label misleading — opens actions sheet, not a video call | Low | `coach_dashboard.dart` | 496-498 | Rename to "Actions" or "Manage" | 0.5h |

---

## 5. Sessions

### 5.1 Create Session
- **File:** `lib/features/coach/presentation/create_session_screen.dart`
- **Status:** FUNCTIONAL
- Full form: title, sport, description, date, time, capacity, price, venue, online toggle
- All fields validated (required checks)
- Calls `CoachService.createSession()` which writes 12 fields to `sessions` collection
- Success: SnackBar + `context.pop()` back to dashboard
- Error: SnackBar with error message
- Loading: `_isCreating` flag disables button + shows loading indicator

### 5.2 Session Write Schemas (Inconsistency)
- **File:** `lib/services/coach_service.dart`
- Two methods write to the same `sessions` collection with different schemas:

| Method | Line | Fields Written |
|---|---|---|
| `bookSession()` | 48-59 | `sessionId`, `coachId`, `playerId`, `sport`, `dateTime`, `status: 'booked'`, `createdAt` |
| `createSession()` | 61-89 | `sessionId`, `coachId`, `playerId`, `title`, `sport`, `description`, `dateTime`, `capacity`, `venue`, `price`, `isOnline`, `status: 'scheduled'`, `createdAt` |

**Problem:** `bookSession()` uses status `'booked'`, `createSession()` uses status `'scheduled'`. The ScheduleTab (line 99-109) only handles `'completed'`, `'cancelled'`, and defaults to `'booked'`/`'scheduled'` → all display as "Upcoming" or "Missed".

### 5.3 Schedule Tab
- **File:** `lib/features/home/presentation/schedule_tab.dart`
- **Status:** DISPLAY ONLY
- Shows all sessions sorted by date/time
- Status logic (line 97-109): `completed` → green, `cancelled` → red, default → blue (upcoming) or orange (missed if past)
- **No tap actions** on session cards — completely static display
- No session detail view
- Error state: cloud-off icon with "Unable to load schedule"
- Loading state: `CircularProgressIndicator`

### 5.4 Session Lifecycle Gaps

| Lifecycle Event | Status | Notes |
|---|---|---|
| Create | FUNCTIONAL | `createSession()` writes to Firestore |
| Read/List | FUNCTIONAL | `getCoachSessions()` streams all sessions |
| Edit | MISSING | No edit screen or service method |
| Cancel | BROKEN | Dialog exists, no Firestore write (D-1) |
| Complete | MISSING | No "mark complete" action anywhere |
| Mark Attendance | MISSING | No attendance tracking |
| View Attendees | MISSING | No attendee list |
| Reschedule | MISSING | Placeholder snackbar (D-3) |
| Join Online | MISSING | No video call integration |

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| S-1 | Session cancel does not write to Firestore | Critical | `coach_dashboard.dart` | 575-579 | Add service method + call | 1h |
| S-2 | No "mark complete" action for sessions | High | — | — | Add complete button + `updateSessionStatus()` | 2h |
| S-3 | No session edit capability | High | — | — | Create edit screen + service method | 4h |
| S-4 | No attendance tracking | Medium | — | — | Add attendance model + UI | 6h |
| S-5 | No session detail view (tap on schedule card) | Medium | `schedule_tab.dart` | 124 | Add tap handler + detail screen | 3h |
| S-6 | Inconsistent write schemas: `bookSession` vs `createSession` | High | `coach_service.dart` | 48-89 | Unify to single method or clearly document when each is used | 2h |
| S-7 | Status `'scheduled'` from `createSession` not handled in ScheduleTab | Medium | `schedule_tab.dart` | 99-109 | Add `'scheduled'` case to switch | 0.5h |
| S-8 | Session cards in ScheduleTab not tappable | Medium | `schedule_tab.dart` | 111-133 | Add `onTap` with navigation to detail | 1h |
| S-9 | No video call integration for online sessions | Medium | — | — | Integrate WebRTC or Jitsi | 16h+ |

---

## 6. Students

### 6.1 Students Tab
- **File:** `lib/features/home/presentation/students_tab.dart`
- **Status:** DISPLAY ONLY
- Reads from `coachPlayersProvider(coachId)` → `PlayerService.getCoachPlayers()` which queries `players` collection where `coachId` matches
- Shows: avatar initial, name, sports list, level, rank, XP points
- Empty state: "No students yet" + "Students will appear when they book sessions"
- Error state: cloud-off icon with "Unable to load students"
- Loading state: `CircularProgressIndicator`

### 6.2 Missing Functionality

| Feature | Status | Notes |
|---|---|---|
| View student list | FUNCTIONAL | Basic card display |
| Search/filter students | MISSING | No search bar or filter options |
| View student profile | MISSING | No tap handler on cards |
| View student progress | MISSING | No progress/metrics view |
| Start chat with student | MISSING | No chat initiation |
| View session history | MISSING | No history view per student |
| Remove student | MISSING | No remove/disconnect action |
| Student performance metrics | MISSING | `playerMetrics` collection exists but no coach view |

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| ST-1 | No search/filter for students | Medium | `students_tab.dart` | — | Add search bar + filter chips | 2h |
| ST-2 | No student profile drill-down | High | `students_tab.dart` | 87-157 | Add `onTap` → student detail screen | 3h |
| ST-3 | No student progress/metrics view | High | — | — | Create coach-facing metrics screen using `playerMetricsProvider` | 4h |
| ST-4 | No chat initiation from student card | Medium | `students_tab.dart` | — | Add chat button → create/find chat + navigate | 2h |
| ST-5 | No session history per student | Medium | — | — | Filter `coachSessionsProvider` by playerId | 2h |
| ST-6 | `coachPlayersProvider` queries `players.coachId` but `bookSession`/`createSession` don't set `coachId` on player doc | High | `player_service.dart` | 63-68 | Ensure `coachId` is set on player docs when they book | 1h |

---

## 7. Earnings

### 7.1 Earnings Tab
- **File:** `lib/features/home/presentation/earnings_tab.dart`
- **Status:** DISPLAY ONLY (with incorrect calculations)
- Shows 4 stat cards: Total Sessions, Completed, Est. Earnings, Hourly Rate
- Session history: shows up to 10 sessions with sport, date, status (Paid/Pending/Cancelled)
- `estimatedEarnings = completedSessions * rate` (line 96) — this only counts sessions with `status == 'completed'`

### 7.2 Calculation Bug
- **File:** `lib/features/home/presentation/earnings_tab.dart:93-96`
- **Status:** BROKEN
- Since `'completed'` status is never written to Firestore (no "mark complete" action exists), `completedSessions` will always be 0
- Therefore `estimatedEarnings` will always be 0
- The `coachStatsProvider` in `coach_service.dart:112-114` has the same issue — `completedSessions` count is always 0

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| E-1 | Earnings always show 0 because no sessions are ever marked "completed" | High | `earnings_tab.dart` | 93-96 | Implement session completion flow (see S-2) | 2h |
| E-2 | No payout/withdrawal functionality | Medium | — | — | Add withdrawal flow + history | 8h+ |
| E-3 | Earnings calculation only counts `hourlyRate × completed count` — ignores actual session `price` field | Medium | `earnings_tab.dart` | 96 | Sum actual `price` fields from completed sessions | 1h |
| E-4 | No date range filter for earnings | Low | — | — | Add month/week/custom filter | 2h |
| E-5 | No earnings export (CSV/PDF) | Low | — | — | Add export functionality | 4h |

---

## 8. Performance / Metrics

### 8.1 Coach-Facing Performance
- **Status:** NOT IMPLEMENTED
- No coach-specific performance tracking screen exists
- `playerMetrics` collection exists in Firestore with fields: `playerId`, `metric`, `value`, `unit`, `loggedAt`
- `PlayerService.logMetric()` exists (line 34-47) but is only used from the player side
- `playerMetricsProvider` exists in providers.dart (line 102-105) but no coach UI consumes it

### 8.2 Player Performance (Accessible to Coach?)
- The `PerformanceTab` exists in `lib/features/player/presentation/performance_tab.dart` but is inside the Player shell
- No coach-accessible version of performance tracking exists
- The Students tab shows basic player data (name, level, rank, XP) but no metrics

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| P-1 | No coach-facing performance/metrics dashboard | High | — | — | Create coach performance screen with student metrics | 8h |
| P-2 | No way for coach to log metrics for students | Medium | — | — | Add metric logging UI in coach session flow | 4h |
| P-3 | No charts/visualizations for coach to view student progress | Medium | — | — | Add chart widgets (fl_chart already in project) | 4h |

---

## 9. Video Analysis

### 9.1 Video Analysis for Coaches
- **Status:** NOT ACCESSIBLE
- `VideoAnalysisScreen` exists at `lib/features/video_analysis/presentation/video_analysis_screen.dart`
- `VideoAnalysisService` exists at `lib/features/video_analysis/data/video_analysis_service.dart`
- Video analysis providers exist at `lib/features/video_analysis/providers/video_analysis_providers.dart`
- **However:** This screen is only accessible from the Player shell. No route to it from Coach shell.
- The "Video Tips" quick action in coach dashboard navigates to `/video-analysis` (line 943) but this route is NOT registered in `app_router.dart`
- The route would fail with the GoRouter error page ("Page Not Found")

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| V-1 | Video analysis not accessible from coach shell | High | `app_router.dart` | — | Register `/video-analysis` route | 0.5h |
| V-2 | Video analysis screen is player-oriented — may need coach-specific version | Medium | `video_analysis_screen.dart` | — | Either make shared or create coach version | 4h |
| V-3 | Coach cannot analyze student videos | Medium | — | — | Add coach video analysis view | 6h |

---

## 10. Academy Jobs

### 10.1 Browse Jobs
- **File:** `lib/features/home/presentation/coach_academy_jobs_screen.dart`
- **Status:** FUNCTIONAL
- Reads from `coachJobsProvider` → `AcademyService.getJobs()` → streams `jobs` collection
- Shows: title, sport, location, salary, experience, perks, description
- Empty state: "No jobs posted yet" + "Check back later"
- Error state: "Unable to load jobs right now"
- Loading state: `CircularProgressIndicator`

### 10.2 Apply for Job
- **File:** `lib/features/home/presentation/coach_academy_jobs_screen.dart:276-310`
- **Status:** FUNCTIONAL
- Confirmation dialog: "Apply for [title]? Your profile will be shared with the academy."
- On confirm: calls `AcademyService.applyForJob()` with `jobId`, `coachId`, `coachName`, `coachEmail`
- Success: SnackBar "Applied for [title] successfully!"
- Shows applied status with color-coded badges

### 10.3 Application Status
- **File:** `lib/features/home/presentation/coach_academy_jobs_screen.dart:228-250`
- **Status:** FUNCTIONAL (display only)
- Reads from `coachApplicationsProvider(coachId)` → streams `jobApplications` collection
- Displays status with color-coded badges: applied (blue), under_review (yellow), interview_scheduled (purple), accepted (green), rejected (red), need_more_info (yellow)
- No way to withdraw application

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| J-1 | No job detail view (expanded/full description) | Medium | `coach_academy_jobs_screen.dart` | 188-193 | Add tap handler → detail screen | 2h |
| J-2 | No withdraw application functionality | Medium | `coach_academy_jobs_screen.dart` | 195-213 | Add withdraw button + service method | 2h |
| J-3 | No job search/filter | Low | — | — | Add search bar + filter chips | 2h |
| J-4 | No notification when application status changes | Medium | — | — | Add push notification on status update | 4h |
| J-5 | `coachJobsProvider` is not filtered by coach — shows ALL jobs globally | Low | `providers.dart` | 162-165 | Already correct for discovery, but could add "recommended for you" | 2h |

---

## 11. Coach Discovery

### 11.1 Browse/Search Coaches
- **File:** `lib/features/home/presentation/coach_discovery_screen.dart`
- **Status:** FUNCTIONAL
- Reads from `coachesStreamProvider` → `CoachService.getCoaches()` → streams `coaches` collection
- Search bar: searches by name, specialization, city (client-side filtering)
- Filter chips: Sport, Location, Rating — each opens a bottom sheet selector
- Shows: initials avatar, name, specialization, rating, experience, city, hourly rate, verified badge, subscription tier badge

### 11.2 Book Session
- **File:** `lib/features/home/presentation/coach_discovery_screen.dart:398-561`
- **Status:** FUNCTIONAL
- "Book Now" button → bottom sheet with date picker, time picker, sport text field
- Form validation: all fields required
- On confirm: calls `CoachService.bookSession()` with `coachId`, `playerId` (current user), `dateTime`, `sport`
- Error handling: catches exceptions + shows error SnackBar
- **Note:** `bookSession()` creates a minimal session (7 fields) vs `createSession()` (12 fields) — see S-6

### 11.3 Missing Functionality

| Feature | Status | Notes |
|---|---|---|
| Coach profile detail view | MISSING | No tap on card → full profile |
| Chat with coach | MISSING | No message/contact button |
| Reviews/ratings display | MISSING | Rating shown but no review list |
| Favorite/save coach | MISSING | No save functionality |

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| CD-1 | No coach profile detail view on tap | Medium | `coach_discovery_screen.dart` | 256-354 | Add tap handler → profile detail screen | 3h |
| CD-2 | No chat initiation from coach card | Medium | — | — | Add message button → create/find chat | 2h |
| CD-3 | Booking creates minimal session (missing title, capacity, venue, price, isOnline) | Medium | `coach_service.dart` | 48-59 | Enhance booking form or unify with createSession | 2h |
| CD-4 | Search is client-side only — loads ALL coaches then filters | Low | `coach_discovery_screen.dart` | 116-131 | Add Firestore text search or Algolia | 4h+ |
| CD-5 | No favorite/save coach functionality | Low | — | — | Add favorites collection + UI | 3h |

---

## 12. Subscriptions

### 12.1 Subscription Display
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:756-913`
- **Status:** DISPLAY ONLY
- Shows plan tier, monthly price, renewal/expiry date, active/inactive badge
- Three tiers: Starter (Free), Professional (₹499/mo), Premium (₹999/mo)

### 12.2 Manage Plan
- **File:** `lib/features/coach/presentation/coach_dashboard.dart:841-912`
- **Status:** DISPLAY ONLY — NO ACTUAL FUNCTIONALITY
- Bottom sheet shows 3 plan options with "Current" badge
- **No onTap handler** on plan options — they are purely visual (line 876-912)
- No payment integration (Stripe, Razorpay, etc.)
- No Firestore write for tier change
- No restore purchases functionality
- No plan comparison feature

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| SUB-1 | Subscription plan options are display-only — no tap handlers | Critical | `coach_dashboard.dart` | 876-912 | Add payment integration + Firestore tier update | 16h+ |
| SUB-2 | No payment gateway integration | Critical | — | — | Integrate Stripe/Razorpay | 16h+ |
| SUB-3 | No subscription expiry enforcement | High | — | — | Add logic to restrict features on expiry | 4h |
| SUB-4 | No downgrade/upgrade confirmation flow | High | — | — | Add confirmation + proration logic | 4h |
| SUB-5 | No restore purchases functionality | Medium | — | — | Add restore flow | 4h |

---

## 13. Notifications

### 13.1 Notification System
- **Status:** NOT IMPLEMENTED — ALL PLACEHOLDERS

Every notification-related UI element in the coach flow is a placeholder:

| Location | Line | Behavior |
|---|---|---|
| `profile_page.dart` → Notifications menu item | 42 | SnackBar "Notifications coming soon" |
| `profile_page.dart` → Privacy & Security | 43 | SnackBar "Privacy & Security coming soon" |
| `profile_page.dart` → Terms of Service | 66 | SnackBar "Terms of Service coming soon" |
| `profile_page.dart` → Privacy Policy | 67 | SnackBar "Privacy Policy coming soon" |
| `coach_dashboard.dart` → "Academy Jobs" quick action | 937 | SnackBar "Academy jobs coming soon" (WRONG — jobs exist) |
| `coach_dashboard.dart` → "Reports" quick action | 945 | SnackBar "Reports coming soon" |
| `coach_dashboard.dart` → "Start Video Session" | 525-529 | SnackBar "Video session feature coming soon" |
| `coach_dashboard.dart` → "Reschedule" | 535-539 | SnackBar "Rescheduling coming soon" |

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| N-1 | No push notification system implemented | High | — | — | Integrate Firebase Cloud Messaging | 8h |
| N-2 | No in-app notification center | High | — | — | Create notifications collection + UI | 6h |
| N-3 | No notification for new session bookings | High | — | — | Send notification on `bookSession()` | 2h |
| N-4 | No notification for job application status changes | Medium | — | — | Send notification on status update | 2h |
| N-5 | "Academy Jobs" quick action shows "coming soon" snackbar but jobs feature exists | Medium | `coach_dashboard.dart` | 937 | Fix to navigate to jobs screen | 0.5h |
| N-6 | Notifications menu in Profile is placeholder | Medium | `profile_page.dart` | 42 | Implement notification list screen | 4h |

---

## 14. Profile

### 14.1 Profile Page
- **File:** `lib/core/widgets/profile_page.dart`
- **Status:** PARTIALLY FUNCTIONAL (shared across all roles)
- Profile header: avatar (with camera icon), name, email, role badge, city
- Sections: Account, Preferences, Support, Other

### 14.2 Menu Items Audit

| Menu Item | Line | Behavior | Status |
|---|---|---|---|
| **Account** | | | |
| Edit Profile | 41 | Opens edit bottom sheet | FUNCTIONAL (partial) |
| Notifications | 42 | SnackBar "coming soon" | DEAD |
| Privacy & Security | 43 | SnackBar "coming soon" | DEAD |
| **Preferences** | | | |
| Dark/Light Mode | 47-56 | Toggles theme via `themeModeProvider` | FUNCTIONAL |
| **Support** | | | |
| Help Center | 60 | Shows static dialog | FUNCTIONAL (static) |
| Contact Us | 61 | Shows static contact info | FUNCTIONAL (static) |
| About | 62 | Shows version 1.0.0 | FUNCTIONAL (static) |
| **Other** | | | |
| Terms of Service | 66 | SnackBar "coming soon" | DEAD |
| Privacy Policy | 67 | SnackBar "coming soon" | DEAD |
| Delete Account | 68 | Confirmation dialog → SnackBar "request submitted" | DEAD — no Firestore delete |
| **Bottom** | | | |
| Sign Out | 76 | Calls `signOut()` → navigates to `/login` | FUNCTIONAL |

### 14.3 Edit Profile
- **File:** `lib/core/widgets/profile_page.dart:227-359`
- **Status:** PARTIALLY FUNCTIONAL
- Fields: Name, Phone, City, Bio
- Calls `AuthService.updateProfile()` which updates `users` collection only (line 309-314)
- **Does NOT update `coaches` collection** — coach-specific fields (specialization, hourlyRate, experience, etc.) are not editable
- Camera icon on avatar (line 132) is display only — no photo upload triggered
- `AuthService.uploadProfilePhoto()` exists (line 129-138) but is never called from ProfilePage
- Validation: name required
- Loading state: `_isSaving` flag + loading spinner

### 14.4 Delete Account
- **File:** `lib/core/widgets/profile_page.dart:430-461`
- **Status:** BROKEN
- Confirmation dialog: "Are you sure you want to delete your account?"
- "Delete" button: shows SnackBar "Account deletion request submitted"
- **Does NOT actually delete** user data from Firestore or Auth

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| PR-1 | Edit Profile only updates `users` collection, not `coaches` | High | `profile_page.dart` | 309-314 | Also call `CoachService.updateCoach()` for coach-specific fields | 2h |
| PR-2 | Camera icon on avatar has no upload functionality | Medium | `profile_page.dart` | 132 | Wire to `AuthService.uploadProfilePhoto()` with image picker | 2h |
| PR-3 | Delete Account is placeholder — no actual deletion | High | `profile_page.dart` | 446-454 | Implement Firebase Auth delete + Firestore cascade delete | 4h |
| PR-4 | Notifications menu is placeholder | Medium | `profile_page.dart` | 42 | Implement notification screen | 4h |
| PR-5 | Privacy & Security is placeholder | Medium | `profile_page.dart` | 43 | Implement privacy settings | 4h |
| PR-6 | Terms of Service is placeholder | Low | `profile_page.dart` | 66 | Add static content page or link | 1h |
| PR-7 | Privacy Policy is placeholder | Low | `profile_page.dart` | 67 | Add static content page or link | 1h |
| PR-8 | No coach-specific profile fields editable (specialization, hourlyRate, experience, etc.) | High | `profile_page.dart` | 227-359 | Add coach-specific fields to edit form | 3h |

---

## 15. Navigation

### 15.1 Registered Routes (from `app_router.dart`)
```
/                    → SplashScreen
/login               → LoginScreen
/signup              → SignupScreen
/forgot-password     → ForgotPasswordScreen
/home                → RoleRouter (dispatches to role shell)
/venues              → VenueDiscoveryScreen
/venues/:id          → VenueDetailScreen
/chat                → ChatListScreen
/chat/:id            → ChatDetailScreen
/coach-discovery     → CoachDiscoveryScreen
/create-session      → CreateSessionScreen
/contracts           → ContractListScreen
/contracts/:id       → ContractDetailScreen
```

### 15.2 Dead/Broken Routes

| Route Used | File | Line | Issue |
|---|---|---|---|
| `'performance'` (no `/` prefix) | `quick_actions_section.dart` | 52 | Missing `/` prefix — routes to player shell tab, not a GoRouter route |
| `'sessions'` (no `/` prefix) | `quick_actions_section.dart` | 58 | Missing `/` prefix — not a registered GoRouter route |
| `/video-analysis` | `coach_dashboard.dart` | 943 | NOT registered in `app_router.dart` — will show error page |

### 15.3 Coach-Specific Navigation
- Coach shell (`coach_shell.dart`) uses `PremiumShell` with bottom nav for 5 tabs (Dashboard, Schedule, Students, Earnings, Jobs)
- Community, Chat, and Profile are accessible via sidebar/nav items but NOT in bottom nav
- Coach-specific routes: `/create-session`, `/coach-discovery`
- **Missing routes:** `/coach-academy-jobs` (embedded in shell tab, no standalone route), `/coach-performance` (doesn't exist)

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| NAV-1 | `/video-analysis` route not registered in app_router.dart | High | `app_router.dart` | — | Add GoRoute for video-analysis | 0.5h |
| NAV-2 | `'performance'` and `'sessions'` in quick_actions use `context.go()` without `/` prefix | Medium | `quick_actions_section.dart` | 52, 58 | Add `/` prefix or use `context.push()` | 0.5h |
| NAV-3 | No standalone route for Academy Jobs screen | Low | — | — | Add `/coach-academy-jobs` route if needed | 0.5h |
| NAV-4 | Error page for 404 routes is generic — no way to report broken link | Low | `app_router.dart` | 144-175 | Add "Report Issue" button on error page | 1h |

---

## 16. Code Quality

### 16.1 Duplicate Code

| Duplicate | File 1 | File 2 | Lines | Description |
|---|---|---|---|---|
| Sport icon mapping | `coach_dashboard.dart` | — | 405-419 | `_getSportIcon()` — could be shared utility |
| Sport color mapping | `coach_dashboard.dart` | — | 421-433 | `_getSportColor()` — could be shared utility |
| Date formatting | `earnings_tab.dart` | `coach_dashboard.dart` | 263-265 / 977-984 | `_formatDate()` duplicated |
| Session time formatting | `coach_dashboard.dart` | — | 392-403 | `_formatSessionTime()` — unique but could be shared |

### 16.2 No SessionModel
- Sessions are stored and read as raw `Map<String, dynamic>` throughout the codebase
- No dedicated `SessionModel` class exists
- No type safety, no field validation, no documentation of expected fields
- This leads to the inconsistent write schemas (S-6) and status handling bugs (S-7)

### 16.3 Dead Code / Unused Code

| Item | File | Line | Status |
|---|---|---|---|
| `CoachService.getCoachStats()` | `coach_service.dart` | 105-134 | Used by `coachStatsProvider` |
| `CoachService.getCoachMonthlyEarnings()` | `coach_service.dart` | 178-202 | Used by `coachMonthlyEarningsProvider` — has operator precedence bug on line 191 |
| `AuthService.uploadProfilePhoto()` | `auth_service.dart` | 129-138 | EXISTS but NEVER called from any UI |
| `AuthService.updatePassword()` | `auth_service.dart` | 145-151 | EXISTS but NEVER called from any UI |
| `AuthService.getActiveUsersCount()` | `auth_service.dart` | 202-208 | Used by admin, not coach |
| `PlayerService.addPoints()` | `player_service.dart` | 49-54 | EXISTS but never called from coach flow |

### 16.4 Operator Precedence Bug
- **File:** `lib/services/coach_service.dart:191`
- **Status:** BUG
```dart
if (dateTime != null && dateTime.isAfter(startOfMonth) || 
    (dateTime != null && dateTime.isAtSameMomentAs(startOfMonth))) {
```
- The `||` has lower precedence than `&&`, so `dateTime != null && dateTime.isAfter(startOfMonth)` is evaluated first, then OR'd with the second condition. This happens to work correctly by accident, but should use explicit parentheses for clarity and correctness:
```dart
if (dateTime != null && (dateTime.isAfter(startOfMonth) || dateTime.isAtSameMomentAs(startOfMonth))) {
```

### 16.5 Missing SessionModel
- **Impact:** High
- Every session read/write uses raw `Map<String, dynamic>`
- No compile-time checking of field names or types
- No single source of truth for session schema
- Makes refactoring extremely error-prone

### Issues

| # | Issue | Severity | File | Line | Fix | Effort |
|---|---|---|---|---|---|---|
| CQ-1 | No SessionModel — all session data is raw Map<String, dynamic> | High | Multiple | — | Create `SessionModel` with fromDoc/toMap | 3h |
| CQ-2 | Duplicate `_formatDate()` in earnings and dashboard | Low | `earnings_tab.dart` / `coach_dashboard.dart` | 263 / 977 | Extract to shared utility | 0.5h |
| CQ-3 | Duplicate sport icon/color mapping | Low | `coach_dashboard.dart` | 405-433 | Extract to shared utility | 0.5h |
| CQ-4 | `AuthService.uploadProfilePhoto()` exists but is never called | Medium | `auth_service.dart` | 129-138 | Wire to profile page camera icon | 1h |
| CQ-5 | `AuthService.updatePassword()` exists but is never called | Medium | `auth_service.dart` | 145-151 | Add change password UI in profile | 2h |
| CQ-6 | Operator precedence bug in `getCoachMonthlyEarnings()` | Low | `coach_service.dart` | 191 | Add explicit parentheses | 0.5h |
| CQ-7 | `parentId` set to player's own UID on signup | Medium | `auth_service.dart` | 98 | Fix semantics — should be actual parent's UID or removed | 1h |

---

## 17. Completion Summary

### By Sub-Module

| Sub-Module | Completion | Working Features | Missing Features |
|---|---|---|---|
| **Authentication** | 90% | Login, signup (3-step), Google sign-in, logout, profile creation | Email verification, onboarding |
| **Dashboard** | 70% | Stats, sessions list, milestones (CRUD), subscription display, 2/4 quick actions | Cancel/complete sessions, subscription management, 2 quick actions |
| **Sessions** | 25% | Create, read/list | Edit, cancel (broken), complete, attendance, attendees, reschedule, join online |
| **Students** | 15% | List display | Search, profile, progress, chat, history, remove |
| **Earnings** | 30% | Display stats and session list | Correct calculations (always 0), payout, export, filters |
| **Performance** | 10% | Player metrics infrastructure exists | Coach-facing dashboard, metric logging, charts |
| **Video Analysis** | 0% | Feature exists in player shell | Coach-accessible version, route registration |
| **Academy Jobs** | 70% | Browse, apply, status display | Withdraw, detail view, search, notifications |
| **Coach Discovery** | 80% | Browse, search, filter, book | Profile detail, chat, reviews |
| **Subscriptions** | 20% | Display plan info | Payment integration, upgrade/downgrade, restore, enforcement |
| **Notifications** | 5% | Placeholder snackbars everywhere | Push notifications, in-app notification center |
| **Profile** | 40% | Edit basic fields, theme toggle, sign out | Coach fields, photo upload, delete account, notifications, privacy |
| **Navigation** | 70% | Most routes functional | 3 broken routes, no video-analysis route |

### Overall Module Completion: ~30%

### Priority Fixes (Top 10)

| Priority | Issue | Severity | Effort |
|---|---|---|---|
| 1 | S-1 / D-1: Cancel session does not write to Firestore | Critical | 1h |
| 2 | SUB-1 / SUB-2: Subscription management is display-only | Critical | 16h+ |
| 3 | S-2: No "mark complete" for sessions | High | 2h |
| 4 | E-1: Earnings always show 0 | High | 2h |
| 5 | ST-6: Coach players query may not match session data | High | 1h |
| 6 | CQ-1: No SessionModel | High | 3h |
| 7 | PR-1 / PR-8: Profile edit doesn't update coach fields | High | 3h |
| 8 | PR-3: Delete Account is placeholder | High | 4h |
| 9 | N-1 / N-2: No notification system | High | 14h+ |
| 10 | NAV-1: `/video-analysis` route not registered | High | 0.5h |

---

## 18. Issue Index

### Critical (3)
- **D-1 / S-1:** Cancel session does not update Firestore (`coach_dashboard.dart:575-579`)
- **SUB-1:** Subscription plan options are display-only (`coach_dashboard.dart:876-912`)
- **SUB-2:** No payment gateway integration (entire subscription flow)

### High (15)
- **D-6:** Video Tips navigates to unregistered route (`coach_dashboard.dart:943`)
- **D-8:** Subscription manage has no upgrade logic (`coach_dashboard.dart:841-912`)
- **S-2:** No "mark complete" for sessions
- **S-3:** No session edit capability
- **S-6:** Inconsistent write schemas (`coach_service.dart:48-89`)
- **ST-2:** No student profile drill-down
- **ST-3:** No student progress/metrics view
- **ST-6:** Coach players query mismatch
- **E-1:** Earnings always show 0
- **SUB-3:** No subscription expiry enforcement
- **SUB-4:** No downgrade/upgrade confirmation
- **N-1:** No push notification system
- **N-2:** No in-app notification center
- **PR-1 / PR-8:** Profile edit doesn't update coach fields
- **PR-3:** Delete Account is placeholder
- **NAV-1:** `/video-analysis` route not registered
- **CQ-1:** No SessionModel

### Medium (22)
- **A-1:** No email verification
- **A-2:** No onboarding flow
- **D-2:** Start Video Session placeholder
- **D-3:** Reschedule placeholder
- **D-4:** Send Message missing chatId
- **D-5:** Academy Jobs quick action placeholder
- **S-4:** No attendance tracking
- **S-5:** No session detail view
- **S-7:** Status `'scheduled'` not handled
- **S-8:** Schedule cards not tappable
- **S-9:** No video call integration
- **ST-1:** No student search
- **ST-4:** No chat from student card
- **ST-5:** No session history per student
- **E-3:** Earnings calculation ignores price field
- **CD-1:** No coach profile detail
- **CD-2:** No chat from coach card
- **CD-3:** Booking creates minimal session
- **J-1:** No job detail view
- **J-2:** No withdraw application
- **J-4:** No job status change notification
- **N-3:** No booking notification
- **N-4:** No job status notification
- **N-5:** Academy Jobs "coming soon" snackbar wrong
- **N-6:** Notifications menu placeholder
- **PR-2:** Camera icon no upload
- **PR-4:** Notifications menu placeholder
- **PR-5:** Privacy placeholder
- **V-2:** Video analysis player-oriented
- **V-3:** Coach cannot analyze student videos
- **NAV-2:** Broken routes in quick_actions
- **CQ-4:** uploadProfilePhoto never called
- **CQ-5:** updatePassword never called
- **CQ-7:** parentId semantics wrong

### Low (10)
- **D-7:** Reports placeholder
- **D-10:** "Join" button label misleading
- **E-4:** No earnings date filter
- **E-5:** No earnings export
- **J-3:** No job search
- **J-5:** Jobs not filtered
- **CD-4:** Client-side search only
- **CD-5:** No favorites
- **PR-6:** Terms of Service placeholder
- **PR-7:** Privacy Policy placeholder
- **NAV-3:** No standalone jobs route
- **NAV-4:** Error page no report button
- **CQ-2:** Duplicate date formatting
- **CQ-3:** Duplicate sport mapping
- **CQ-6:** Operator precedence bug

---

*End of audit report. Total issues found: 50 (3 Critical, 15 High, 22 Medium, 10 Low)*
