# Coaching workspace reorganization – audit

## What changed (by stakeholder)

### Players & parents
- Primary navigation is now booking-first: **Home → Find a coach → Bookings → Messages → Growth / My players**. Player development tools (performance, video, squad goals, challenges), venues, community, agreements and profile remain available from the grouped drawer/rail.
- New **Bookings** screen (`my_bookings_screen.dart`) with Requests / Upcoming / History / All filters. Parents choose which linked player's bookings to view.
- Booking flow uses real availability, re-checks the slot before submitting, blocks duplicate taps, and requires parents to pick a linked player. Success is reported as **“Request sent”** (not confirmed); totals are labelled as estimates because no payment is collected.
- Session detail: statuses `booked`/`pending` show “Awaiting coach”, `rejected` shows “Declined”; unknown statuses are labelled honestly (“Status unavailable”) rather than guessed as “Missed”.
- Parent dashboard training log now requires selecting the player, validates metrics (non-negative, accuracy 0–100), and its quick actions stay inside the workspace instead of leaving the shell.

### Coaches
- Primary navigation: **Home → Requests → Schedule → Players → Messages**, with Availability, Earnings, Business overview, jobs/offers grouped in the drawer.
- Only the coach sees check-in / complete / reschedule controls on a session. Rejected requests release their slot; past or malformed slots are filtered out.
- Booking requests no longer auto-link a player to a coach at request time; linking happens on acceptance.

### Academy & admin
- Same shared `RoleWorkspace` shell; existing screens mapped 1:1 (batches, coaches, recruitment, advertising; users, venues, operations, coupons).

### Engineering
- `LazyTabStack` mounts tabs on first visit and keeps their state (verified by test).
- `GoRouter` is now created once via `appRouterProvider` (previously rebuilt on every theme change, which reset navigation). Routes taking `extra` no longer crash on a missing value.
- Tests: `test/workspace_test.dart` (destination order per role, lazy tabs, workspace home at 360/800/1280 px for every role), `test/booking_entry_test.dart` (filter/status semantics), `test/widget_test.dart` (app boots without Firebase; theme change preserves route). `flutter analyze` reports no errors (85 pre-existing infos/warnings, none in new files).

## Remaining gaps (need backend work)
1. **Firestore rules are broadly permissive.** UI-level restrictions (coach-only session actions, parent-only booking for linked players) are not enforced server-side.
2. **Slot reservation is not atomic.** The pre-submit recheck reduces but does not eliminate double bookings; a transaction or Cloud Function should reserve the slot.
3. **No payment capture.** Amounts shown are estimates; a checkout step and refund/cancellation policy are needed before charging.
4. **Agreement consistency.** Parent is set as signer when booking for a child; existing agreement flows should be reviewed to ensure the correct party signs and the player record is linked on acceptance.
5. Legacy shells (`player_shell.dart`, coach/parent shells) are still in the tree and can be removed once the new workspace is signed off.