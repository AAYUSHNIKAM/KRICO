# 08 — Data Architecture

---

## Entity Relationship Diagram

```
┌──────────┐     ┌──────────────┐     ┌──────────┐
│  Player  │─────│    Session   │─────│  Coach   │
└──────────┘     └──────────────┘     └──────────┘
     │                                      │
     │                                      │
     ▼                                      ▼
┌──────────┐     ┌──────────────┐     ┌──────────┐
│  Parent  │     │   Contract   │     │ Academy  │
└──────────┘     └──────────────┘     └──────────┘
                                              │
                                              │
                                              ▼
                                        ┌──────────┐
                                        │  Batch   │
                                        └──────────┘

┌──────────┐     ┌──────────────┐     ┌──────────┐
│  Venue   │─────│   Booking    │     │   User   │
└──────────┘     └──────────────┘     └──────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Player      │  │ Community    │  │ Notification │
│  Metric      │  │ Post         │  │              │
└──────────────┘  └──────────────┘  └──────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Achievement │  │  Squad Goal  │  │  Video       │
│              │  │              │  │  Analysis    │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## Core Entities

### User
- **Collection:** `users/{uid}`
- **Purpose:** Authentication root and shared profile data across all roles
- **Fields:** `uid`, `email`, `name`, `phone`, `role` (enum: player/coach/academy/parent/admin), `city`, `photoUrl`, `lastLoginAt`, `isActive`, `createdAt`, `updatedAt`
- **Relationships:** One-to-one with role-specific entity (Player, Coach, Academy). Parent links to Player via `parentId`.

---

### Player
- **Collection:** `players/{playerId}`
- **Purpose:** Player-specific data — sports profile, statistics, gamification state
- **Fields:** `playerId`, `parentId`, `name`, `age`, `sports[]`, `level`, `rank`, `points`, `championshipWins`, `tournamentPoints`, `avatarUrl`, `coachId`, `academyId`, `createdAt`, `updatedAt`
- **Relationships:** Belongs to User (1:1). May link to Coach (N:1), Academy (N:1). Links to Parent via `parentId`.

---

### Coach
- **Collection:** `coaches/{coachId}`
- **Purpose:** Coaching profile, credentials, availability, and business data
- **Fields:** `coachId`, `name`, `email`, `phone`, `city`, `specialization`, `experience`, `hourlyRate`, `rating`, `totalReviews`, `isVerified`, `isSubscribed`, `subscriptionTier`, `academyId`, `photoUrl`, `createdAt`, `updatedAt`
- **Relationships:** Belongs to User (1:1). May be affiliated with Academy (N:1). Has many Sessions, many Players.

---

### Academy
- **Collection:** `academies/{academyId}`
- **Purpose:** Academy profile, metrics, and operational data
- **Fields:** `academyId`, `name`, `email`, `phone`, `city`, `reputationPoints`, `coachPlacements`, `totalStudents`, `isVerified`, `createdAt`, `updatedAt`
- **Relationships:** Belongs to User (1:1). Has many Coaches, many Batches, many Placements.

---

### Session
- **Collection:** `sessions/{sessionId}`
- **Purpose:** Training sessions — the core transactional unit of the platform
- **Fields:** `sessionId`, `coachId`, `playerId`, `title`, `sport`, `description`, `dateTime`, `capacity`, `venue`, `price`, `isOnline`, `status` (scheduled/completed/cancelled/missed), `createdAt`
- **Relationships:** Belongs to Coach (N:1). Belongs to Player (N:1). May reference Venue.

---

### Venue
- **Collection:** `venues/{venueId}`
- **Purpose:** Sports facility listings
- **Fields:** `venueId`, `name`, `address`, `city`, `sports[]`, `amenities[]`, `pricing`, `images[]`, `rating`, `isActive`, `ownerId`, `createdAt`, `updatedAt`
- **Relationships:** Belongs to Venue Owner (N:1). Has many Bookings.

---

### Contract
- **Collection:** `contracts/{contractId}`
- **Purpose:** Legally binding agreements between stakeholders
- **Fields:** `contractId`, `type` (coach-player/academy-coach/venue-rental), `partyAId`, `partyBId`, `partyARole`, `partyBRole`, `amount`, `platformFee`, `opportunityFee`, `contractSavings`, `totalAmount`, `status` (draft/pending/active/completed/cancelled), `terms`, `isEscrowActive`, `digitalSignatureA`, `digitalSignatureB`, `signedAtA`, `signedAtB`, `createdAt`, `updatedAt`
- **Relationships:** Links two Users/roles. References Sessions or Bookings optionally.

---

### Batch
- **Collection:** `batches/{batchId}`
- **Purpose:** Academy-bounded group of students with a coach
- **Fields:** `batchId`, `academyId`, `name`, `sport`, `capacity`, `enrolled`, `schedule`, `coachId`, `isActive`, `createdAt`, `updatedAt`
- **Relationships:** Belongs to Academy (N:1). May have Coach (N:1). Contains many Players.

---

### Chat
- **Collection:** `chats/{chatId}`
- **Subcollection:** `messages/{messageId}`
- **Purpose:** Direct messaging between any two or more users
- **Chat fields:** `chatId`, `participants[]`, `isActive`, `lastMessage`, `lastMessageTime`, `lastMessageSender`, `unreadCount` (Map<userId, count>), `createdAt`
- **Message fields:** `messageId`, `chatId`, `senderId`, `text`, `messageType` (text/image/video/file), `mediaUrl`, `createdAt`
- **Relationships:** Links Users (M:N). Messages belong to Chat (1:N).

---

### Player Metric
- **Collection:** `playerMetrics/{metricId}`
- **Purpose:** Time-series performance data logged by players and coaches
- **Fields:** `playerId`, `metric` (speed/stamina/technique/strength/agility), `value`, `unit`, `loggedAt`
- **Relationships:** Belongs to Player (N:1).

---

### Achievement
- **Collection:** `playerAchievements/{achievementId}`
- **Purpose:** Record of achievement unlocks per player
- **Fields:** `playerId`, `achievementId` (references AchievementModel.id), `unlockedAt`
- **Relationships:** Belongs to Player (N:1).

---

### Community Post
- **Planned collection:** `posts/{postId}`
- **Purpose:** User-generated content in the community feed
- **Fields:** `postId`, `userId`, `content`, `mediaUrl`, `likesCount`, `commentsCount`, `createdAt`, `updatedAt`
- **Subcollection:** `comments/{commentId}` — `commentId`, `userId`, `content`, `createdAt`
- **Top-level collection:** `likes/{likeId}` — `postId`, `userId`
- **Relationships:** Belongs to User (N:1). Has many Comments, many Likes.

---

### Squad Goal
- **Collection:** `squadGoals/{goalId}`
- **Purpose:** Team-based goal setting and tracking
- **Fields:** `goalId`, `title`, `description`, `sport`, `status`, `memberIds[]`, `progress`, `target`, `createdAt`, `updatedAt`
- **Relationships:** Links to Players (M:N).

---

### Video Analysis
- **Collection:** `videoAnalysis/{videoId}`
- **Purpose:** Uploaded training videos and their analysis results
- **Fields:** `videoId`, `playerId`, `coachId`, `title`, `videoUrl`, `thumbnailUrl`, `analysisData` (future), `status`, `uploadedAt`
- **Relationships:** Belongs to Player (N:1). May be viewed by Coach.

---

### Notification
- **Planned collection:** `notifications/{notificationId}`
- **Purpose:** In-app notification history
- **Fields:** `notificationId`, `userId`, `type` (session/message/achievement/payment/system), `title`, `body`, `data` (Map — routing payload), `isRead`, `createdAt`
- **Relationships:** Belongs to User (N:1).

---

### Payment / Transaction
- **Planned collection:** `transactions/{transactionId}`
- **Purpose:** Financial transaction records
- **Fields:** `transactionId`, `fromUserId`, `toUserId`, `amount`, `platformFee`, `type` (session/contract/subscription/refund), `status` (pending/completed/failed/refunded), `paymentMethod`, `referenceId` (session/contract/booking ID), `createdAt`

---

### Attendance
- **Planned subcollection:** `sessions/{sessionId}/attendance/{playerId}`
- **Purpose:** Per-session attendance records
- **Fields:** `playerId`, `status` (present/absent/late/excused), `markedBy` (coachId), `markedAt`

---

### Wallet
- **Planned collection:** `wallets/{userId}`
- **Purpose:** Digital wallet balance and transaction history
- **Fields:** `userId`, `balance`, `lockedBalance` (escrow), `updatedAt`
- **Subcollection:** `transactions/{transactionId}` — mirror of main transactions

---

## Firestore Indexes

### Existing (from `firestore.indexes.json`)

| Collection | Fields | Purpose |
|-----------|--------|---------|
| sessions | `coachId ASC`, `dateTime ASC` | Coach sessions sorted by date |
| coachMilestones | `coachId ASC`, `createdAt ASC` | Coach milestones in creation order |
| playerMetrics | `playerId ASC`, `loggedAt DESC` | Player metrics newest first |
| chats | `participants ASC`, `isActive ASC`, `lastMessageTime DESC` | User's chats sorted by recent |
| academyPlacements | `academyId ASC`, `placedAt DESC` | Academy placements newest first |
| coachJobs | `status ASC`, `createdAt DESC` | Active jobs newest first |
| coachJobs | `academyId ASC`, `createdAt DESC` | Academy's jobs newest first |
| squadGoals | `sport ASC`, `status ASC`, `createdAt DESC` | Goal discovery by sport |
| squadGoals | `memberIds ASC`, `createdAt DESC` | User's goals sorted by recent |
| videoAnalysis | `playerId ASC`, `uploadedAt DESC` | Player's videos newest first |
| contracts | `partyAId ASC`, `createdAt DESC` | User's contracts newest first |
| batches | `academyId ASC`, `isActive ASC` | Active batches per academy |
| campaigns | `academyId ASC`, `createdAt DESC` | Academy campaigns newest first |

### Missing (Required for Launch)

| Collection | Fields | Reason |
|-----------|--------|--------|
| sessions | `playerId ASC`, `dateTime ASC` | Player sessions sorted by date (currently uses client-side sort) |
| sessions | `playerId ASC`, `status ASC`, `dateTime ASC` | Filter player sessions by status |
| posts | `createdAt DESC` | Community feed ordering |
| notifications | `userId ASC`, `createdAt DESC` | User notifications newest first |
| players | `points DESC` | Leaderboard ordering |

---

## Key Data Relationships

```
User (1) ──→ Player (1)
User (1) ──→ Coach (1)
User (1) ──→ Academy (1)
Parent (1) ──→ Player (N)  [via parentId]
Coach (1) ──→ Session (N)
Player (1) ──→ Session (N)
Coach (N) ──→ Academy (1)  [via academyId]
Academy (1) ──→ Batch (N)
Batch (N) ──→ Coach (1)  [via coachId]
Player (1) ──→ Metric (N)
Player (1) ──→ Achievement (N)
Player (N) ──→ Squad Goal (M)  [via memberIds]
Player (1) ──→ Video Analysis (N)
Chat (M) ──→ User (N)  [via participants]
Contract (1) ──→ Party A (User) + Party B (User)
Venue (1) ──→ Booking (N)
User (1) ──→ Notification (N)
User (1) ──→ Post (N)
Post (1) ──→ Comment (N)  [subcollection]
Post (N) ──→ Like (M)  [top-level collection]
```

---

## Data Flow Principles

1. **Single source of truth:** Role-specific data lives in role-specific collections (`players/`, `coaches/`, `academies/`). `users/` contains only cross-cutting profile data.
2. **Read-optimized:** Denormalize where necessary for read performance. Example: `session` includes `playerId` and `coachId` directly rather than requiring a join.
3. **Write-then-read:** Writes use `FieldValue.serverTimestamp()` for consistency. Reads use stream providers for real-time updates.
4. **Minimal writes:** Avoid updating parent documents when children change. Example: Session status changes don't rewrite the coach document — the session query provides the data.
5. **Security at document level:** Firestore rules enforce that users can only read/write their own data or data they're authorized to access.
6. **Index for every query pattern:** Any `where()` + `orderBy()` combination must have a corresponding composite index. Client-side sorting is never acceptable in production.
