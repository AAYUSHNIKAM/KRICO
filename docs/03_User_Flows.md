# 03 — User Flows

---

## Player Signup

```
Player opens app
    ↓
Splash screen → Auth check
    ↓
[No account] → Signup Screen
    ↓
Enter name, email, phone, password
    ↓
Select role: Player
    ↓
(Optional) Enter city, sports interests
    ↓
Create Account
    ↓
Firebase Auth: createUserWithEmailAndPassword
    ↓
Firestore: create users/{uid} document
    ↓
Firestore: create players/{uid} document
    ↓
Auto-login → Role Router → Player Shell
    ↓
[First time] → Onboarding overlay
    ↓
Welcome → Player Dashboard
```

---

## Coach Signup

```
Coach opens app
    ↓
Splash screen → Auth check
    ↓
[No account] → Signup Screen
    ↓
Enter name, email, phone, password
    ↓
Select role: Coach
    ↓
Enter specialization, experience, city, hourly rate
    ↓
Create Account
    ↓
Firebase Auth: createUserWithEmailAndPassword
    ↓
Firestore: create users/{uid} document
    ↓
Firestore: create coaches/{uid} document
    ↓
Auto-login → Role Router → Coach Shell
    ↓
[First time] → Complete profile prompt
    ↓
Coach Dashboard
```

---

## Player Books Session with Coach

```
Player → Coach Discovery
    ↓
Search/filter coaches (sport, location, rating)
    ↓
Browse coach cards (rating, experience, rate, verification)
    ↓
Tap "Book Now" on a coach card
    ↓
Booking bottom sheet opens
    ↓
Select date (date picker)
    ↓
Select time (time picker)
    ↓
Enter sport
    ↓
[Optional] Add notes
    ↓
Tap "Confirm Booking"
    ↓
coachService.bookSession() → sessions/{sessionId}
    ↓
Firestore: create session with status "booked"
    ↓
Send notification to coach
    ↓
[success] → Snackbar "Session booked successfully!"
    ↓
Redirect → Dashboard (upcoming session visible)
```

---

## Coach Creates Session

```
Coach → Schedule tab
    ↓
Tap "Create Session" button
    ↓
Create Session Screen
    ↓
Enter: title, sport, description, date, time, duration
    ↓
Enter: capacity, venue, price
    ↓
Toggle: isOnline
    ↓
Tap "Create Session"
    ↓
coachService.createSession() → sessions/{sessionId}
    ↓
Firestore: create session with status "scheduled"
    ↓
[success] → Dashboard (session visible in schedule)
    ↓
[optional] → Notify eligible players
```

---

## Player Cancels Booking

```
Player → Dashboard → Upcoming Session Card
    ↓
Tap "View Details" or navigate to Schedule
    ↓
View session detail
    ↓
Tap "Cancel Booking"
    ↓
Confirmation dialog: "Are you sure?"
    ↓
[Confirm] → coachService.cancelSession()
    ↓
Firestore: update session status → "cancelled"
    ↓
Refund processing (if applicable)
    ↓
Send notification to coach
    ↓
Return to Dashboard (session removed from upcoming)
```

---

## Coach Marks Attendance

```
Coach → Dashboard → Session Card
    ↓
Tap session → Session Detail
    ↓
Session is "in_progress" or "completed"
    ↓
Tap "Mark Attendance"
    ↓
Student list with checkboxes
    ↓
Select present/absent for each student
    ↓
Tap "Confirm Attendance"
    ↓
Firestore: update attendance records
    ↓
If present:
    ↓
Firestore: increment player XP
    ↓
Check achievement unlock conditions
    ↓
    [unlocked] → Achievement notification
    ↓
Return to Session Detail
```

---

## Achievement Unlock

```
Player completes action (session, win, milestone, etc.)
    ↓
Platform event triggers achievement check
    ↓
AchievementService.checkUnlocks(playerId)
    ↓
Match action against AchievementModel requirements
    ↓
[Requirement met AND not already unlocked]
    ↓
Firestore: write to playerAchievements/{id}
    ↓
Firebase: send push notification
    ↓
Player sees achievement celebration UI:
    - Dashboard achievement badge lights up
    - Achievement tab shows unlocked state
    - XP bonus awarded
    - (optional) Leaderboard points
```

---

## XP Gain and Level Progression

```
Player completes any XP-earning action:
    - Attends session (+10 XP)
    - Logs performance metric (+5 XP)
    - Unlocks achievement (+50 XP)
    - Books session (+3 XP)
    - Posts in community (+2 XP)
    - Receives coach rating (+15 XP)
    ↓
playerService.addPoints(playerId, amount)
    ↓
Firestore: FieldValue.increment(points) on players/{playerId}
    ↓
Player dashboard re-reads → reflects new XP
    ↓
LevelModel.getLevel(newXp) checks if threshold crossed
    ↓
[Level up] → Level up notification
    ↓
Dashboard header shows new level + progress toward next
```

---

## Rank Promotion

```
RankModel defines thresholds (e.g., rank 1 = Bronze, rank 5 = Diamond)
    ↓
Player accumulates championship wins and tournament points
    ↓
Periodic rank evaluation (daily/weekly cron or event-triggered)
    ↓
[Player crosses rank threshold]
    ↓
Firestore: update players/{uid}.rank
    ↓
Push notification: "Congratulations! You've been promoted to Silver!"
    ↓
Dashboard rank badge updates
    ↓
Leaderboard position recalculated
```

---

## Coach Discovery Flow

```
Player → Coaches tab (shell navigation)
    ↓
Coach list loads from Firestore (coachesStreamProvider)
    ↓
[Optional] Type in search bar → client-side filter by name/specialization/location
    ↓
[Optional] Tap filter chip → Sport / Location / Rating
    ↓
    Sport filter: bottom sheet → select sport → filter
    ↓
    Location filter: bottom sheet → select city → filter
    ↓
    Rating filter: bottom sheet → select minimum rating → filter
    ↓
Browse filtered coach cards
    ↓
Tap "Book Now" → Booking sheet
    ↓
Complete booking (see "Player Books Session" flow)
```

---

## Chat Flow

```
Player → Chat tab (shell navigation)
    ↓
Chat list loads (userChatsProvider)
    ↓
[Empty] → "No conversations yet" with CTA to start
    ↓
Tap chat → Chat Detail Screen
    ↓
Message history loads (chatMessagesProvider)
    ↓
Type message in text field → tap send (or Enter)
    ↓
chatService.sendMessage()
    ↓
Firestore: create message doc in chats/{id}/messages/
    ↓
Firestore: update chats/{id} with lastMessage, lastMessageTime
    ↓
Message appears in real-time (stream)
    ↓
Scroll to bottom
    ↓
[New message from other user] → Real-time update (stream listener)
```

---

## Community Post Flow

```
Player → Community tab (shell navigation)
    ↓
Feed loads (planned: posts collection, stream provider)
    ↓
Tap "Share something..." text field
    ↓
Type post content
    ↓
[Optional] Tap media buttons (image/video/emoji)
    ↓
Tap "Post"
    ↓
postService.createPost()
    ↓
Firestore: create post document
    ↓
Post appears at top of feed
    ↓
Other users can:
    ↓
    Like: postService.toggleLike(postId, userId)
    ↓
    Comment: postService.addComment(postId, userId, text)
    ↓
    Share: native share sheet
```

---

## Venue Booking Flow

```
Player → Venue Discovery (via GoRouter: /venues)
    ↓
Venue list loads (venuesStreamProvider)
    ↓
Search/filter by sport, name, location
    ↓
Tap venue card → Venue Detail Screen
    ↓
View venue info: photos, amenities, pricing, availability, location
    ↓
Tap "Book Venue"
    ↓
Select date, time slot, duration
    ↓
Select sport/activity
    ↓
Review pricing
    ↓
Tap "Confirm Booking"
    ↓
venueService.bookVenue()
    ↓
Firestore: create booking document
    ↓
Payment processing
    ↓
Confirmation → notification to venue owner
```

---

## Academy Hires Coach

```
Academy → Coaches tab
    ↓
View current coaches and open positions
    ↓
Tap "Post Job" → Job creation form
    ↓
Enter: title, sport, location, salary, experience required, description, perks
    ↓
Tap "Post" → Firestore: coachJobs collection
    ↓
Coach applications come in (jobApplications collection)
    ↓
Review applicant profiles → tap "View Profile"
    ↓
[Interested] → "Invite for Trial"
    ↓
Firestore: create invitation in coachInvitations
    ↓
Coach receives notification → accepts/rejects
    ↓
[Accepted] → Academy can finalize:
    ↓
Create contract (contractService.createContract)
    ↓
Coach joins academy → coaches/{uid}.academyId set
    ↓
Assign coach to batches (assignCoachToBatch)
```

---

## Contract Signing Flow

```
Party A initiates contract (booking, hiring, agreement)
    ↓
contractService.createContract()
    ↓
Firestore: contracts/{id} with status "draft"
    ↓
Party B receives notification → views contract detail
    ↓
Reviews: terms, amount, fees, duration
    ↓
[Accepts] → Sign contract button
    ↓
contractService.signContract(contractId, partyId, signature)
    ↓
Firestore: update signature fields, signedAt timestamps
    ↓
[Both parties signed] → Update status to "active"
    ↓
[Activates] → Payment escrow if applicable
    ↓
Both parties receive confirmation
```

---

## Admin Approval Flow

```
[Flagged content / reported user / dispute]
    ↓
Notification sent to admin panel
    ↓
Admin opens support queue
    ↓
Reviews: reported content, user history, context
    ↓
Actions available:
    ↓
    Warn user → Firestore: add warning to user record
    ↓
    Suspend user → set isActive = false, revoke sessions
    ↓
    Ban user → delete/disable account
    ↓
    Remove content → delete post/comment
    ↓
    Dismiss report → no action needed
    ↓
Resolution logged → reporter receives notification
```

---

## Payment Flow

```
[Booking confirmed / Contract signed]
    ↓
Payment intent created
    ↓
Player/payer sees payment summary:
    - Base amount
    - Platform fee (10%)
    - Opportunity fee (10%)
    - Savings (-10%)
    - Total
    ↓
Select payment method (UPI / Card / Net Banking / Wallet)
    ↓
Payment gateway processing
    ↓
[Success] → Firestore: update payment status
    ↓
    → Notification: "Payment successful"
    ↓
    → Funds held in escrow (if contract)
    ↓
[Failure] → Retry / Change method / Cancel booking
    ↓
Service completion triggers payout:
    ↓
    Attendance marked → funds released to coach/venue
    ↓
    Platform fee credited to platform account
```

---

## Attendance + XP Loop

```
Session time arrives
    ↓
Coach marks attendance
    ↓
[Player present]
    ↓
    playerService.addPoints(playerId, 10)  // Session XP
    ↓
    coachService.markAttended(sessionId, playerId)
    ↓
    [Player attended 5+ consecutive sessions]
        ↓
        Achievement check: "Streak" achievement
    ↓
    Dashboard updates:
        - Session count increments
        - XP bar visible
        - Streak badge (if applicable)
```

---

## Parent Monitors Child

```
Parent logs in → Parent Shell
    ↓
Parent Dashboard → overview of linked children
    ↓
Select child → child's dashboard view
    ↓
View:
    - Upcoming sessions
    - Recent activity/attendance
    - Performance metric trends
    - Coach feedback and ratings
    - Achievement progress
    ↓
[Action] → Message coach directly
    ↓
[Action] → Book/reschedule session for child
    ↓
[Action] → View and approve contracts
    ↓
[Action] → Make payments
```
