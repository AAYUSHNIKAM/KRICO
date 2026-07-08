# App Flow: Complete User Journey Design

---

## First Launch Flow

```
App Icon Tap
    |
    v
[Splash Screen] -- 2s animated brand reveal
    |
    v
[Firebase Auth Check]
    |
    +-- User Logged In --> [Role Router] --> Dashboard
    |
    +-- No User --> [Login Screen]
                      |
                      +-- "Don't have an account?" --> [Signup Screen]
                                                          |
                                                          v
                                                    Step 1: Role Selection
                                                    (Player | Coach | Academy | Parent)
                                                          |
                                                          v
                                                    Step 2: Personal Info
                                                    (Name, Email, Phone)
                                                          |
                                                          v
                                                    Step 3: Credentials
                                                    (Password, Terms)
                                                          |
                                                          v
                                                    Firebase Auth Create
                                                          |
                                                          v
                                                    Role-specific Doc Created
                                                    (users/coaches/academies/players)
                                                          |
                                                          v
                                                    [Onboarding Profile Setup]
                                                          |
                                                          +-- Player: Select sports, age, level, avatar
                                                          +-- Coach: Specialization, experience, rate, certificates
                                                          +-- Academy: Sports offered, logo, description, address
                                                          +-- Parent: Add child player(s), link existing
                                                          |
                                                          v
                                                    [Home / Dashboard]
```

## Login Flow

```
[Login Screen]
    |
    +-- Email/Password Tab
    |     |
    |     v
    |   Enter Email + Password
    |     |
    |     v
    |   Firebase Auth Sign In
    |     |
    |     +-- Success --> [Home / Dashboard]
    |     +-- Error --> Show error toast
    |
    +-- Google Sign-In Tab
    |     |
    |     v
    |   Google Auth Provider
    |     |
    |     v
    |   Firebase Auth Sign In
    |     |
    |     +-- First time --> Profile creation
    |     +-- Returning --> [Home / Dashboard]
    |
    +-- Forgot Password?
          |
          v
        [Forgot Password Screen]
          |
          v
        Enter Email --> Reset Link Sent --> Back to Login
```

## Player Flow (Primary)

```
[Player Dashboard]
    |-- KPI Section: Points, Rank, Championship Wins, Tournament Points
    |-- Quick Actions: Find Coach, Book Venue, Log Session, View Progress
    |-- Performance Section: Recent metrics (charts/stats)
    |-- Sessions Section: Upcoming and recent sessions
    |-- Coach Carousel: Top/recommended coaches
    |-- Achievement Section: Latest unlocked achievements
    |-- Community Preview: Recent community posts
    |-- Activity Timeline: Recent actions (sessions, achievements, goals)

    +-- [Performance Tab]
    |     |-- Metric charts (speed, accuracy, duration over time)
    |     |-- Video analysis history
    |     |-- Progress trends
    |
    +-- [AI Coach / Video Analysis Tab]
    |     |-- Upload video from gallery
    |     |-- Select sport
    |     |-- View latest analysis result (pose score, feedback)
    |     |-- Browse video history
    |     |-- Request coach review
    |
    +-- [Community Tab]
    |     |-- Create post
    |     |-- Browse feed (mock posts currently)
    |     |-- Like, comment, share
    |     |-- View other users
    |
    +-- [Chat Tab]
    |     |-- Chat list (sorted by recent)
    |     |-- Open chat detail
    |     |-- Send/receive messages
    |
    +-- [Coaches Tab]
    |     |-- Browse coach listings
    |     |-- Search by name/specialization
    |     |-- View coach profile
    |     |-- Book session
    |
    +-- [Squad Goals Tab]
    |     |-- View active squad goals
    |     |-- Create new goal (title, sport, target, reward, members, deadline)
    |     |-- Log contribution to goals
    |     |-- Track progress
    |
    +-- [Profile Tab]
          |-- View/edit profile
          |-- Settings
          |-- Theme toggle
          |-- Sign out
```

## Coach Flow

```
[Coach Dashboard]
    |-- Header: Photo, name, specialization, rating, subscription info, hourly rate
    |-- Stats: Total Sessions, Students, Monthly Earnings, Rating
    |-- Upcoming Sessions: Next 5 sessions with sport, time, student
    |-- Career Milestones: Trackable goals (add, complete, delete)
    |-- Subscription Card: Current plan, price, renewal, manage
    |-- Quick Actions: Messages, Academy Jobs, Video Tips, Reports

    +-- [Schedule Tab]
    |     |-- Calendar view of all sessions
    |     |-- Create new session
    |     |-- Reschedule/cancel sessions
    |
    +-- [Students Tab]
    |     |-- List of students (players assigned to coach)
    |     |-- View student profiles
    |     |-- Message student
    |     |-- Track student progress
    |
    +-- [Earnings Tab]
    |     |-- Monthly earnings summary
    |     |-- Total earnings
    |     |-- Per-session breakdown
    |
    +-- [Jobs Tab]
    |     |-- Browse academy job listings
    |     |-- Apply for jobs
    |     |-- Track application status
    |     |-- View academy invitations
    |
    +-- [Community Tab]
    |     |-- Same as Player
    |
    +-- [Chat Tab]
    |     |-- Same as Player
    |
    +-- [Profile Tab]
          |-- Edit coach profile
          |-- Manage subscription
          |-- Settings, theme, sign out
```

## Academy Flow

```
[Academy Dashboard]
    |-- Header: Logo, name, sports, verification status
    |-- Stats: Total Students, Active Coaches, Reputation Points, Placements
    |-- Active Batches: List with name, enrollment, schedule, sport
    |-- Advertising Suite: Create campaigns (Product Ads, Social Boost, Community)
    |-- Coach Placements: Recent placements list

    +-- [Batches Tab]
    |     |-- All batches list
    |     |-- Create batch (name, sport, capacity, schedule)
    |     |-- Edit batch
    |     |-- Delete batch (soft)
    |     |-- Assign coach to batch
    |
    +-- [Coaches Tab]
    |     |-- List of academy coaches
    |     |-- Invite new coaches
    |     |-- View coach profiles
    |     |-- Assign coaches to batches
    |
    +-- [Advertising Tab]
    |     |-- Create campaigns
    |     |-- View active campaigns
    |     |-- Budget management
    |
    +-- [Jobs Tab]
    |     |-- Post new jobs
    |     |-- View posted jobs
    |     |-- Review applications
    |     |-- Manage job status
    |
    +-- [Chat Tab]
    |     |-- Same as Player
    |
    +-- [Profile Tab]
          |-- Edit academy profile
          |-- Settings, theme, sign out
```

## Parent Flow

```
[Parent Dashboard]
    |-- Header: Welcome message, wins summary, player count, XP
    |-- Stats: Championship Wins, Tournament Points, Active Players, Avg XP
    |-- Student Progress: Player cards with XP bar, level, wins
    |-- Quick Actions: Track Metrics, Find Coach, Book Venue, View Reports
    |-- Smart Input Panel: Log metrics (speed, duration, distance, accuracy)

    +-- [Coaches Tab]
    |     |-- Browse coaches (same as player)
    |     |-- Book for child
    |
    +-- [Progress Tab]
    |     |-- View child's progress reports
    |     |-- Performance charts
    |     |-- Session history
    |
    +-- [Chat Tab]
    |     |-- Same as Player
    |
    +-- [Profile Tab]
          |-- Edit profile
          |-- Manage linked players
          |-- Settings, theme, sign out
```

## Admin Flow

```
[Admin Dashboard]
    |-- Header: Platform Control, pending tasks count
    |-- Stats: Total Users, Venues, Revenue, Active Users
    |-- Task Master: Recent admin tasks
    |-- Manual Venue Addition Form
    |-- Premium Coupons: Active coupons list, release new coupon

    +-- [Venues Tab]
    |     |-- All venues list
    |     |-- Venue detail
    |     |-- Add venue form
    |
    +-- [Users Tab]
    |     |-- All platform users
    |     |-- Filter by role
    |
    +-- [Coupons Tab]
    |     |-- Active/past coupons
    |     |-- Release coupon
    |     |-- Toggle coupon status
    |
    +-- [Profile Tab]
          |-- Edit profile
          |-- Settings, theme, sign out
```

## Booking Flow (Ideal - To Be Built)

```
User finds Coach/Venue
    |
    v
View Profile/Detail
    |
    v
Select Date & Time
    |
    v
Select Duration
    |
    v
Review Pricing (base + platform fee)
    |
    v
Apply Coupon (optional)
    |
    v
Confirm Booking
    |
    v
Payment (UPI / Card / Wallet)
    |
    v
Booking Confirmed
    |
    +-- Notification to Coach/Venue
    +-- Calendar event created
    +-- Contract auto-generated (if applicable)
    +-- Session appears in both calendars
```

## AI Analysis Flow

```
Player records/selects video
    |
    v
Select sport from dropdown
    |
    v
Upload to Firebase Storage
    |
    v
Firestore doc created (status: "processing")
    |
    v
Cloud Function triggers AI analysis
(pose estimation, form scoring, feedback generation)
    |
    v
Status updated to "completed"
poseScore, jointAngles, feedback populated
    |
    v
Player notified (push notification)
    |
    v
Player views results:
  - Pose score (/100)
  - Color-coded feedback (Good Form / Needs Work)
  - Detailed feedback text
  - Joint angle breakdown (future)
    |
    v
Optional: Submit to Coach for review
    |
    v
Coach reviews and adds personal feedback
    |
    v
Player sees coach feedback alongside AI feedback
```

## Squad Goal Flow

```
Player creates goal
  - Title, sport, target value, metric, reward
  - Add teammates (by user ID)
  - Set deadline
    |
    v
Goal appears in creator's and teammates' feeds
    |
    v
Any member logs contribution (+1 unit)
    |
    v
Progress bar updates in real-time
Member contribution tracked individually
    |
    v
Goal reaches 100%
    |
    v
Goal marked "completed"
Reward description displayed
XP awarded to all members
    |
    v
Achievement unlocked (if applicable)
```

## Logout Flow

```
User taps Sign Out (sidebar/drawer footer)
    |
    v
Confirmation dialog? (future: optional)
    |
    v
Firebase Auth signOut()
    |
    v
Clear local state (Riverpod providers reset)
    |
    v
Navigate to Login Screen
```

## Deep Linking & External Entry Points

| Entry Point | Target | Flow |
|---|---|---|
| Push Notification (new message) | Chat Detail | Deep link to specific chat |
| Push Notification (session reminder) | Session Detail | Open session in Calendar |
| Push Notification (achievement) | Achievement | Open Achievement tab |
| Email verification link | Profile | Verify email flow |
| Password reset link | Password Reset | Show new password form |
| Share invite link | Signup | Pre-fill referral code |
```

