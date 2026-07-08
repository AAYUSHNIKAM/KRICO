# Navigation Tree: Complete Routing Architecture

---

## Router Configuration

**Technology**: GoRouter with Riverpod integration
**Base Path Strategy**: Role-based routing after authentication

```
/ (splash)
/login
/signup
/forgot-password
/home --> RoleRouter -> role-specific shell
/parent --> ParentShell
/player --> PlayerShell
/coach --> CoachShell
/academy --> AcademyShell
/admin --> AdminShell
/venues
/venues/:id
/chat
/chat/:id
/coach-discovery
/create-session
/contracts
/contracts/:id
```

---

## Desktop Navigation (Sidebar + TopBar)

```
+--------------------------------------------------+
| [Sidebar 260px]    | [TopBar]                     |
|-------------------|-------------------------------|
| Logo: SportsEco    | (breadcrumb / page title)    |
|                    |                               |
| User Avatar        |                               |
| User Name          |                               |
| Role Label         |                               |
|--------------------|                               |
| Nav Items:         |                               |
|   icon + label     |  [Content Area]               |
|   icon + label     |                               |
|   ...              |  IndexedStack                 |
|                    |  (current screen)             |
|--------------------|                               |
| Settings           |                               |
| Theme Toggle       |                               |
| Sign Out           |                               |
+--------------------------------------------------+
```

## Tablet Navigation (Collapsed Sidebar + TopBar)

```
+-----------------------------------------------+
| [Col 80px]  | [TopBar]                        |
|-------------|----------------------------------|
| (app icon)  | (page title)                    |
|             |                                  |
| Nav icons   |  [Content Area]                  |
| (no label)  |                                  |
|             |  IndexedStack                    |
|             |  (current screen)                |
|-------------|                                  |
| Settings    |                                  |
| Theme       |                                  |
| Sign Out    |                                  |
+-----------------------------------------------+
```

## Mobile Navigation (Drawer + BottomNav)

```
+-----------------------------------------------+
| [AppBar]                                       |
| [Menu]  Page Title                             |
|------------------------------------------------|
|                                                |
|  [Content Area]                                |
|                                                |
|                                                |
|                                                |
|------------------------------------------------|
| [Bottom Navigation]                             |
|  Icon1 | Icon2 | Icon3 | Icon4 | Icon5        |
+-----------------------------------------------+

[DRAWER - slides from left]
+------------------------------+
| Logo: SportsEco              |
| User info (avatar, name)     |
|------------------------------|
| NAVIGATION                   |
|   Nav Item 1                 |
|   Nav Item 2                 |
|   ...                        |
|------------------------------|
| PREFERENCES                  |
|   Settings                   |
|   Theme Toggle               |
|------------------------------|
|   Sign Out                   |
+------------------------------+
```

---

## Player Navigation Tree

### Top-Level Tabs (BottomNav on Mobile: 0-4)

```
[0] Dashboard
    |-- KPI Section (points, rank, wins, tournament points)
    |-- Quick Actions (4 buttons grid)
    |-- Performance Summary (chart/metrics)
    |-- Upcoming Sessions
    |-- Coach Carousel (horizontal scroll)
    |-- Latest Achievements
    |-- Community Preview
    |-- Activity Timeline

[1] Performance
    |-- Performance charts by metric
    |-- Progress trends over time
    |-- Video analysis history
    |-- Metric comparison

[2] AI Coach (Video Analysis)
    |-- Upload section (sport selector + upload button)
    |-- Latest analysis result
    |-- Video history list
    |-- Coach review requests

[3] Community
    |-- Create post (text input + media buttons)
    |-- Feed (posts from all users)
    |-- Like/Comment/Share actions

[4] Chat
    |-- Chat list (sorted by recency)
    |-- Badge for unread counts
    |-- Tap to open Chat Detail

[Extra - Drawer/Full Nav]
[5] Coaches
    |-- Coach listings (grid/list)
    |-- Search bar
    |-- Filter by specialization
    |-- Coach detail (tap to view)
    |-- Book session action

[6] Squad Goals
    |-- Active goals list
    |-- Create new goal button (FAB)
    |-- Goal cards with progress, members, deadline
    |-- Log contribution button

[7] Profile
    |-- User info display
    |-- Edit profile
    |-- Settings
    |-- Theme toggle
    |-- Sign out
```

## Coach Navigation Tree

### Top-Level Tabs (BottomNav on Mobile: 0-4)

```
[0] Dashboard
    |-- Header (photo, name, rating, plan, rate)
    |-- Stats row (sessions, students, earnings, rating)
    |-- Upcoming sessions list (5 items)
    |-- Career milestones (add/complete/delete)
    |-- Subscription card (plan, price, manage)
    |-- Quick actions (messages, jobs, video tips, reports)

[1] Schedule
    |-- Sessions calendar view
    |-- Create session button
    |-- Session list by date

[2] Students
    |-- Student list (grid/list)
    |-- Search students
    |-- Student card (name, sport, progress)
    |-- Message student action
    |-- View student profile

[3] Earnings
    |-- Monthly earnings summary
    |-- Total earnings
    |-- Session breakdown
    |-- Charts (future)

[4] Jobs
    |-- Academy job listings
    |-- Job detail view
    |-- Apply for job
    |-- Application status tracking
    |-- Academy invitations

[Extra - Drawer/Full Nav]
[5] Community (same as Player)
[6] Chat (same as Player)
[7] Profile
    |-- Edit coach profile
    |-- Manage subscription
    |-- Certificates
    |-- Settings
    |-- Theme toggle
    |-- Sign out
```

## Academy Navigation Tree

### Top-Level Tabs (BottomNav on Mobile: 0-4)

```
[0] Dashboard
    |-- Header (logo, name, sports, verification)
    |-- Stats row (students, coaches, reputation, placements)
    |-- Active batches list
    |-- Advertising Suite card
    |-- Placements card

[1] Batches
    |-- Batch list
    |-- Create batch button (FAB)
    |-- Batch detail (name, capacity, schedule, sport)
    |-- Assign coach to batch
    |-- Edit/delete batch

[2] Coaches
    |-- Academy coaches list
    |-- Invite coach button
    |-- Coach profiles
    |-- Assign to batch
    |-- Track coach performance

[3] Advertising
    |-- Campaign list
    |-- Create campaign (type, name, budget)
    |-- Campaign performance (future)

[4] Jobs
    |-- Posted jobs list
    |-- Post new job
    |-- Job applications review
    |-- Manage job status

[Extra - Drawer/Full Nav]
[5] Chat (same as Player)
[6] Profile
    |-- Edit academy profile
    |-- Verify academy
    |-- Settings
    |-- Theme toggle
    |-- Sign out
```

## Parent Navigation Tree

### Top-Level Tabs (BottomNav on Mobile: 0-4)

```
[0] Dashboard
    |-- Header (welcome, wins, players, XP)
    |-- Stats row (wins, tournament points, active players, avg XP)
    |-- Students progress cards
    |-- Quick actions (metrics, coach, venue, reports)
    |-- Smart input panel (metric logging)

[1] Coaches (same as Player discovery)
[2] Progress
    |-- Child progress reports
    |-- Performance charts
    |-- Session history
    |-- Achievement overview

[3] Chat (same as Player)
[4] Profile (same pattern)
```

## Admin Navigation Tree

### Top-Level Tabs (BottomNav on Mobile: 0-4)

```
[0] Dashboard
    |-- Stats (users, venues, revenue, active users)
    |-- Task master list
    |-- Venue addition form
    |-- Coupon management

[1] Venues
    |-- Venue list
    |-- Venue detail
    |-- Add venue (form)
    |-- Verify venue

[2] Users
    |-- All users list
    |-- Filter by role
    |-- User detail (future)

[3] Coupons
    |-- Active coupons list
    |-- Release coupon form
    |-- Toggle coupon status

[4] Profile (same pattern)
```

## Shared Routes (Not Role-Specific)

```
/venues              --> VenueDiscoveryScreen (all roles)
/venues/:id          --> VenueDetailScreen (all roles)
/chat                --> ChatListScreen (all roles)
/chat/:id            --> ChatDetailScreen (all roles)
/contracts           --> ContractListScreen (all roles)
/contracts/:id       --> ContractDetailScreen (all roles)
/coach-discovery     --> CoachDiscoveryScreen (player, parent)
/create-session      --> CreateSessionScreen (coach role only)
```

## Deep Navigation Flows

### Booking Flow (Future)
```
Dashboard -> "Find Coach" -> CoachDiscovery -> CoachDetail -> BookSession -> Calendar -> Payment -> Confirm
                                                                                                      |
                                                                                                      v
                                                                                                Session added
                                                                                                Contract created
                                                                                                Notification sent
```

### Video Analysis Flow
```
PlayerShell -> AI Coach Tab -> Upload Video -> Select Sport -> Upload -> View Results -> Request Coach Review
                                                                                                      |
                                                                                                      v
                                                                                            Coach reviews in dashboard
                                                                                            Coach provides feedback
                                                                                            Player notified
```

### Academy Hiring Flow
```
AcademyDashboard -> Jobs Tab -> Post Job -> Job Listed
                                      |
                                      v
                            Coach discovers in Jobs Tab
                            Coach applies
                                      |
                                      v
                            Academy reviews application
                            Academy sends invitation
                                      |
                                      v
                            Coach accepts
                            Contract created
                            Coach assigned to batch
```

## Responsive Breakpoint Strategy

| Breakpoint | Layout | Navigation |
|---|---|---|
| < 600px (Mobile) | Single column | BottomNav (5 items) + Drawer |
| 600-900px (Tablet) | 2-column flex | Collapsed Sidebar (icons only) + TopBar |
| > 900px (Desktop) | Multi-column | Full Sidebar (260px) + TopBar |

BottomNav shows the first 5 nav items. All items accessible via the drawer on mobile, or the full sidebar on desktop.
