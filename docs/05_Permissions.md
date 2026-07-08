# 05 — Permissions Matrix

## Legend
| Symbol | Meaning |
|--------|---------|
| ✓ | Full access (create/read/update/delete) |
| R | Read only |
| C | Create only |
| U | Update only |
| D | Delete only |
| CR | Create + Read |
| RU | Read + Update |
| CRU | Create + Read + Update |
| — | No access |
| ~ | Conditional (see notes) |

---

## Permission Matrix

| Action | Player | Coach | Academy | Parent | Venue | Admin |
|--------|--------|-------|---------|--------|-------|-------|
| **Authentication** | | | | | | |
| Register account | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| Login | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Delete own account | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| View own profile | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| View any user profile | — | — | — | — | — | ✓ |
| **Profile** | | | | | | |
| Edit own profile | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Upload profile photo | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| View linked children | — | — | — | ✓ | — | — |
| Manage children | — | — | — | ✓ | — | — |
| **Sessions** | | | | | | |
| Create session | — | ✓ | — | — | — | — |
| Book session | ✓ | — | — | ~ | — | — |
| Cancel own booking | ✓ | ~ | — | ~ | — | — |
| Cancel any session | — | ~ | — | — | — | ✓ |
| Mark attendance | — | ✓ | — | — | — | — |
| View own sessions | ✓ | ✓ | — | ~ | — | — |
| View all sessions | — | ~ | ~ | — | ~ | ✓ |
| **Coaches** | | | | | | |
| Create coach profile | — | ✓ | — | — | — | — |
| Edit coach profile | — | ✓ | — | — | — | ✓ |
| List coaches | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| View coach detail | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Rate coach | ✓ | — | — | ✓ | — | — |
| Assign coach to batch | — | — | ✓ | — | — | — |
| Invite coach | — | — | ✓ | — | — | — |
| **Academy** | | | | | | |
| Create academy profile | — | — | ✓ | — | — | — |
| Edit academy profile | — | — | ✓ | — | — | ✓ |
| View academy list | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| View academy detail | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Create batch | — | — | ✓ | — | — | — |
| Manage batch | — | ~ | ✓ | — | — | — |
| **Venues** | | | | | | |
| Create venue | — | — | — | — | ✓ | ✓ |
| Edit venue | — | — | — | — | ✓ | ✓ |
| List venues | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| View venue detail | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Book venue | ✓ | ✓ | ✓ | — | — | — |
| Manage venue bookings | — | — | — | — | ✓ | ✓ |
| **Community** | | | | | | |
| Create post | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Edit own post | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Delete own post | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Delete any post | — | — | — | — | — | ✓ |
| Like post | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Comment on post | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Delete any comment | — | — | — | — | — | ✓ |
| Report content | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| Moderate content | — | — | — | — | — | ✓ |
| **Chat** | | | | | | |
| Send message | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Receive message | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Delete own message | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Delete any message | — | — | — | — | — | ✓ |
| Create group chat | ✓ | ✓ | ✓ | — | — | ✓ |
| **Performance** | | | | | | |
| Log own metrics | ✓ | — | — | — | — | — |
| Log metrics for others | — | ✓ | — | ✓ | — | — |
| View own metrics | ✓ | — | — | ~ | — | — |
| View others' metrics | — | ~ | ~ | ~ | — | ✓ |
| **Gamification** | | | | | | |
| Earn XP | ✓ | — | — | — | — | — |
| Unlock achievements | ✓ | — | — | — | — | — |
| View leaderboard | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Edit leaderboard | — | — | — | — | — | ✓ |
| **Contracts** | | | | | | |
| Create contract | ~ | ~ | ✓ | ~ | ~ | — |
| Sign contract (own) | ✓ | ✓ | ✓ | ~ | ✓ | — |
| View own contracts | ✓ | ✓ | ✓ | ~ | ✓ | ✓ |
| View all contracts | — | — | — | — | — | ✓ |
| Terminate contract | ~ | ~ | ~ | ~ | ~ | ✓ |
| **Payments** | | | | | | |
| Make payment | ✓ | — | ✓ | ✓ | — | — |
| Receive payment | — | ✓ | ✓ | — | ✓ | — |
| View own transactions | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| View platform revenue | — | — | — | — | — | ✓ |
| Issue refund | — | ~ | ~ | — | ~ | ✓ |
| **Notifications** | | | | | | |
| View own notifications | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Manage notification prefs | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Send broadcast notification | — | — | — | — | — | ✓ |
| **Squad Goals** | | | | | | |
| Create squad goal | ✓ | ✓ | — | — | — | — |
| Join squad goal | ✓ | — | — | — | — | — |
| Update goal progress | ✓ | ✓ | — | — | — | — |
| Delete goal | ✓ | ✓ | — | — | — | ✓ |
| **Video Analysis** | | | | | | |
| Upload video | ✓ | — | — | — | — | — |
| View own analysis | ✓ | ✓ | — | ~ | — | — |
| Delete own video | ✓ | — | — | — | — | — |
| Delete any video | — | — | — | — | — | ✓ |
| **Analytics** | | | | | | |
| View personal analytics | ✓ | ✓ | — | — | ✓ | ✓ |
| View student analytics | — | ✓ | ✓ | ~ | — | ✓ |
| View platform analytics | — | — | — | — | — | ✓ |
| Export reports | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Admin** | | | | | | |
| Manage users | — | — | — | — | — | ✓ |
| Moderate content | — | — | — | — | — | ✓ |
| Manage coupons | — | — | — | — | — | ✓ |
| View system health | — | — | — | — | — | ✓ |
| Configure platform | — | — | — | — | — | ✓ |
| Manage support tickets | — | — | — | — | — | ✓ |
| Override any restriction | — | — | — | — | — | ✓ |

---

## Conditional Notes

| Action | Condition |
|--------|-----------|
| Parent books session for child | Only for linked children |
| Parent cancels booking | Only for sessions booked for linked children |
| Parent views child metrics | Only for linked children |
| Parent signs contract | Only as guardian for linked child |
| Coach cancels session | Only sessions they created, before cancellation window |
| Coach views student metrics | Only for students they coach |
| Academy views student data | Only for students enrolled in their batches |
| Academy edits batch | Only batches they created |
| Academy assigns coach | Only to their own batches |
| Venue views sessions | Only for sessions at their venue |
| Venue issues refund | Only for bookings at their venue |
| Player creates contract | Only as party B in coach-player contracts |
| Coach creates contract | Only as party A with their students |
| Parent views contract | Only for contracts involving their child |
| Any stakeholder terminates contract | Only their own contracts, subject to terms |

---

## Permission Enforcement Rules

1. **Server-side (Firestore Security Rules):** Primary enforcement layer. All reads/writes validated against auth UID and document ownership.
2. **Client-side (UI):** Buttons, navigation items, and actions are conditionally rendered based on `UserModel.role`.
3. **Riverpod providers:** Role-based data access is enforced at the provider level — a coach provider is never available in a player shell.
4. **Admin override:** Admin accounts bypass all document-level ownership checks but all actions are logged to an audit trail.
5. **Parent proxy:** Parent actions on behalf of a child are recorded with both `actorId` (parent UID) and `targetId` (child UID) for audit.
