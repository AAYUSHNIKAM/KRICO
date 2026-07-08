# Firebase Architecture: Collections, Security, Indexes & Relationships

---

## Current Collections

| Collection | Doc ID | Purpose | Status |
|---|---|---|---|
| `users` | uid | Base user profile for all roles | Active |
| `coaches` | uid | Coach-specific profile data | Active |
| `players` | uid | Player-specific profile data | Active |
| `academies` | uid | Academy-specific profile data | Active |
| `venues` | auto-id | Sports venue listings | Active |
| `sessions` | auto-id | Training sessions (bookings) | Active |
| `batches` | auto-id | Academy batch groups | Active |
| `chats` | auto-id | Chat conversations | Active |
| `messages` | auto-id (subcollection of chats) | Chat messages | Active |
| `contracts` | auto-id | Legal agreements | Active |
| `videoAnalysis` | auto-id | AI video analysis results | Active |
| `playerMetrics` | auto-id | Performance data logs | Active |
| `squadGoals` | auto-id | Team challenge goals | Active |
| `playerAchievements` | auto-id | Unlocked achievements | Active |
| `coachMilestones` | auto-id | Coach career milestones | Active |
| `coupons` | auto-id | Promotional discount codes | Active |
| `adminTasks` | auto-id | Platform admin tasks | Active |
| `campaigns` | auto-id | Academy advertising campaigns | Active |
| `academyPlacements` | auto-id | Coach placement records | Active |
| `coachJobs` | auto-id | Academy job postings | Active |
| `jobApplications` | auto-id | Coach job applications | Active |
| `coachInvitations` | auto-id | Academy -> Coach invitations | Active |
| `notifications` | auto-id | User notifications | Active |

## Document Schemas & Field Details

### users/{uid}
```
{
  email: string,
  name: string,
  phone: string,
  role: enum("parent","player","coach","academy","admin"),
  photoUrl: string?,
  city: string?,
  bio: string?,
  isActive: boolean,
  lastLoginAt: timestamp?,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### coaches/{uid}
```
{
  coachId: string (== uid),
  name: string,
  email: string,
  phone: string,
  photoUrl: string?,
  city: string?,
  specialization: string?,
  experience: int,
  hourlyRate: double,
  bio: string?,
  rating: double,
  totalReviews: int,
  subscriptionTier: enum("Starter","Professional","Elite"),
  isSubscribed: boolean,
  subscriptionExpiry: timestamp?,
  certificates: string[]?,
  workExperience: map[]?,
  isVerified: boolean,
  academyId: string?,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### players/{uid}
```
{
  playerId: string (== uid),
  parentId: string,
  name: string,
  age: int?,
  sports: string[]?,
  level: string?,
  rank: int,
  points: int,
  championshipWins: int,
  tournamentPoints: int,
  avatarUrl: string?,
  coachId: string?,
  academyId: string?,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### academies/{uid}
```
{
  academyId: string (== uid),
  name: string,
  email: string,
  phone: string,
  logoUrl: string?,
  description: string?,
  address: string?,
  city: string?,
  sports: string[]?,
  website: string?,
  socialLinks: map<string,string>?,
  reputationPoints: int,
  coachPlacements: int,
  totalStudents: int,
  isVerified: boolean,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### venues/{auto-id}
```
{
  venueId: string,
  name: string,
  description: string?,
  address: string?,
  city: string?,
  latitude: double?,
  longitude: double?,
  amenities: string[]?,
  images: string[]?,
  contactPhone: string?,
  website: string?,
  openingHours: string?,
  sports: string[]?,
  capacity: int?,
  rating: double,
  isGoogleSourced: boolean,
  googlePlaceId: string?,
  isActive: boolean,
  addedBy: string?,
  isVerified: boolean,
  pricePerHour: double?,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### sessions/{auto-id}
```
{
  sessionId: string,
  coachId: string,
  playerId: string,
  title: string?,
  sport: string,
  description: string?,
  dateTime: timestamp,
  capacity: int?,
  venue: string?,
  price: double?,
  isOnline: boolean?,
  status: enum("booked","scheduled","completed","cancelled"),
  createdAt: timestamp
}
```

### contracts/{auto-id}
```
{
  contractId: string,
  type: enum("coaching","academy","subscription"),
  partyAId: string,
  partyBId: string,
  partyARole: string,
  partyBRole: string,
  amount: double,
  platformFee: double,
  opportunityFee: double,
  contractSavings: double,
  totalAmount: double,
  status: enum("draft","pending","active","completed","cancelled","disputed"),
  startDate: timestamp?,
  endDate: timestamp?,
  terms: string?,
  digitalSignatureA: string?,
  digitalSignatureB: string?,
  signedAtA: timestamp?,
  signedAtB: timestamp?,
  isEscrowActive: boolean,
  escrowReleaseDate: timestamp?,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

## Cross-Collection Relationships

```
users.uid
  |-- 1:1 --> coaches.coachId (if role == coach)
  |-- 1:1 --> players.playerId (if role == player)
  |-- 1:1 --> academies.academyId (if role == academy)
  |-- 1:N --> sessions.playerId (as player)
  |-- 1:N --> sessions.coachId (as coach)
  |-- 1:N --> chats.participants[] (array contains)
  |-- 1:N --> contracts.partyAId or partyBId
  |-- 1:N --> notifications.userId

players.playerId
  |-- N:1 --> coaches.coachId (assigned coach)
  |-- N:1 --> academies.academyId (enrolled academy)
  |-- 1:N --> playerMetrics.playerId
  |-- 1:N --> videoAnalysis.playerId
  |-- N:N --> squadGoals.memberIds[] (array contains)
  |-- 1:N --> playerAchievements.playerId

coaches.coachId
  |-- N:1 --> academies.academyId (affiliated academy)
  |-- 1:N --> sessions.coachId
  |-- 1:N --> coachMilestones.coachId

academies.academyId
  |-- 1:N --> batches.academyId
  |-- 1:N --> campaigns.academyId
  |-- 1:N --> academyPlacements.academyId
  |-- 1:N --> coachJobs.academyId
  |-- 1:N --> coachInvitations.academyId

venues.venueId (referenced in sessions.venue by name string, not FK)
```

## Security Rules Analysis

### Current Rules

The current `firestore.rules` have several issues:

1. **Players write**: `allow write: if request.auth != null;` -- Any authenticated user can write any player document, including modifying other players' data. Should be `request.auth.uid == playerId`.

2. **Venues write**: `allow write: if request.auth != null;` -- Any authenticated user can modify venues. Should be restricted to admin or owner.

3. **Sessions**: `allow read, write: if request.auth != null;` -- No participant-based restriction. Should check if user is coachId or playerId.

4. **Batches**: No relationship check to academy. Should verify the user owns the academy.

5. **Catch-all rule**: `match /{document=**} { allow read, write: if request.auth != null; }` -- This overrides more specific rules above it and grants broad access.

### Recommended Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // === USERS ===
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }

    // === COACHES ===
    match /coaches/{coachId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == coachId;
      allow update: if request.auth.uid == coachId;
      allow delete: if request.auth.token.isAdmin == true;
    }

    // === PLAYERS ===
    match /players/{playerId} {
      allow read: if request.auth != null &&
        (request.auth.uid == playerId ||
         request.auth.uid == resource.data.parentId);
      allow create: if request.auth.uid == playerId;
      allow update: if request.auth.uid == playerId ||
        request.auth.uid == resource.data.parentId;
      allow delete: if request.auth.token.isAdmin == true;
    }

    // === ACADEMIES ===
    match /academies/{academyId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == academyId;
    }

    // === VENUES ===
    match /venues/{venueId} {
      allow read: if true;
      allow create: if request.auth.token.isAdmin == true;
      allow update: if request.auth.token.isAdmin == true ||
        request.auth.uid == resource.data.addedBy;
      allow delete: if request.auth.token.isAdmin == true;
    }

    // === SESSIONS ===
    match /sessions/{sessionId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.coachId ||
         request.auth.uid == resource.data.playerId);
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (request.auth.uid == resource.data.coachId ||
         request.auth.uid == resource.data.playerId);
    }

    // === CHATS ===
    match /chats/{chatId} {
      allow read, write: if request.auth != null &&
        request.auth.uid in resource.data.participants;
      match /messages/{messageId} {
        allow read, write: if request.auth != null &&
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }

    // === CONTRACTS ===
    match /contracts/{contractId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.partyAId ||
         request.auth.uid == resource.data.partyBId);
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (request.auth.uid == resource.data.partyAId ||
         request.auth.uid == resource.data.partyBId);
    }

    // === BATCHES ===
    match /batches/{batchId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        request.auth.uid == resource.data.academyId;
    }

    // === VIDEO ANALYSIS ===
    match /videoAnalysis/{videoId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.playerId ||
         request.auth.uid == resource.data.coachId);
      allow write: if request.auth != null &&
        request.auth.uid == resource.data.playerId;
    }

    // === SQUAD GOALS ===
    match /squadGoals/{goalId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null &&
        request.auth.uid == resource.data.creatorId;
      allow update: if request.auth != null &&
        request.auth.uid in resource.data.memberIds;
    }

    // === PLAYER METRICS ===
    match /playerMetrics/{metricId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.playerId;
    }

    // === PLAYER ACHIEVEMENTS ===
    match /playerAchievements/{achievementId} {
      allow read: if request.auth != null &&
        request.auth.uid == resource.data.playerId;
      allow write: if request.auth != null;
      // Server-side Cloud Functions should manage this
    }

    // === COACH MILESTONES ===
    match /coachMilestones/{milestoneId} {
      allow read: if request.auth != null &&
        request.auth.uid == resource.data.coachId;
      allow write: if request.auth != null &&
        request.auth.uid == resource.data.coachId;
    }

    // === NOTIFICATIONS ===
    match /notifications/{notificationId} {
      allow read: if request.auth != null &&
        request.auth.uid == resource.data.userId;
      allow write: if request.auth != null;
    }

    // === ADMIN COLLECTIONS ===
    match /coupons/{couponId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.isAdmin == true;
    }

    match /adminTasks/{taskId} {
      allow read: if request.auth.token.isAdmin == true;
      allow write: if request.auth.token.isAdmin == true;
    }

    // === ACADEMY OPERATIONS ===
    match /campaigns/{campaignId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.academyId;
    }

    match /academyPlacements/{placementId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.academyId;
    }

    match /coachJobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.academyId;
    }

    match /jobApplications/{appId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.coachId ||
         request.auth.uid in get(/databases/$(database)/documents/coachJobs/$(resource.data.jobId)).data.academyId);
      allow write: if request.auth.uid == resource.data.coachId;
    }

    match /coachInvitations/{invitationId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.academyId ||
        request.auth.uid == resource.data.coachId;
    }

    // === DENY ALL OTHER ACCESS ===
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Indexes Analysis

### Current Indexes (in firestore.indexes.json)

| Collection | Fields | Purpose | Status |
|---|---|---|---|
| sessions | coachId ASC, dateTime ASC | Coach's session calendar | Active |
| coachMilestones | coachId ASC, createdAt ASC | Coach milestone timeline | Active |
| playerMetrics | playerId ASC, loggedAt DESC | Player performance history | Active |
| chats | participants ASC, isActive ASC, lastMessageTime DESC | User's active chats | Active |
| academyPlacements | academyId ASC, placedAt DESC | Placement history | Active |
| coachJobs | status ASC, createdAt DESC | Active job listings | Active |
| coachJobs | academyId ASC, createdAt DESC | Academy's job posts | Active |
| squadGoals | sport ASC, status ASC, createdAt DESC | Goals by sport | Active |
| squadGoals | memberIds ASC, createdAt DESC | Player's goals | Active |
| videoAnalysis | playerId ASC, uploadedAt DESC | Player's videos | Active |
| contracts | partyAId ASC, createdAt DESC | User's contracts | Active |
| batches | academyId ASC, isActive ASC | Academy's batches | Active |
| campaigns | academyId ASC, createdAt DESC | Academy's campaigns | Active |

### Recommended Additional Indexes

| Collection | Fields | Reason |
|---|---|---|
| sessions | playerId ASC, dateTime DESC | Player's upcoming sessions |
| sessions | coachId ASC, status ASC, dateTime ASC | Coach's active sessions filtering |
| players | parentId ASC, name ASC | Parent's children listing |
| contracts | partyBId ASC, createdAt DESC | Second-party contract view |
| notifications | userId ASC, createdAt DESC | User's notification feed |
| notifications | userId ASC, isRead ASC, createdAt DESC | Unread notifications first |
| videoAnalysis | coachId ASC, status ASC, uploadedAt DESC | Coach's pending reviews |
| jobApplications | coachId ASC, createdAt DESC | Coach's application history |
| jobApplications | jobId ASC, status ASC | Academy's applicant management |

## Storage Architecture

### Bucket Structure
```
/profile_photos/{userId} -- Profile pictures (all roles)
/videos/{playerId}/{videoId}.mp4 -- Training videos
/venues/{venueId}/ -- Venue images
/campaigns/{campaignId}/ -- Campaign media
/contracts/{contractId}/ -- Signed contract PDFs
```

### Storage Rules (current)
- Profile photos: public read, owner write
- Videos: authenticated read, player write
- Catch-all: public read, authenticated write

### Recommended Storage Rule Improvements
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }
    match /videos/{playerId}/{videoId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == playerId;
      allow delete: if request.auth.uid == playerId;
    }
    match /venue_images/{venueId}/{imageId} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true;
    }
    match /campaigns/{academyId}/{campaignId}/{fileName} {
      allow read: if true;
      allow write: if request.auth.uid == academyId;
    }
    match /contracts/{contractId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /{allPaths=**} {
      allow read: if false;
      allow write: if false;
    }
  }
}
```

## Future-Proofing Recommendations

### 1. Denormalized Counters
Use distributed counters (subcollections) for high-write fields:
- `venues/{venueId}/ratings/{ratingId}` -- individual ratings
- `sessions/{sessionId}/attendees/{playerId}` -- attendance records
- `users/{userId}/loginHistory/{loginId}` -- login timestamps

### 2. Soft Deletes
All collections should support soft deletes via `isActive: false` and `deletedAt: timestamp` fields. Currently implemented in: venues, chats, batches. Needs extension to: sessions, contracts, users.

### 3. Aggregation with Cloud Functions
Use Firebase Cloud Functions (or Extensions) for:
- Recalculating coach average rating when new review added
- Updating academy totalStudents when player enrolls
- Updating player rank based on points leaderboard
- Auto-completing squad goals when target reached
- Processing video analysis (trigger on videoAnalysis create)

### 4. Schema Versioning
Add `schemaVersion: int` field to all root collections for future migration support.

### 5. Audit Logs
Add `auditLogs/{logId}` collection for tracking sensitive operations:
- Contract status changes
- Payment transactions
- Role changes
- Account deletions

### 6. Event Sourcing for Financial Data
For financial transactions, maintain an immutable `transactions/{transactionId}` collection with operation type, amount, from, to, timestamp. Contracts and earnings should be derived from this source of truth.
