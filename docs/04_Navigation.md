# 04 — Navigation

## Design Philosophy

- **Thumb zone first:** Primary actions placed in the lower third of the screen on phone
- **Progressive disclosure:** Surface core info on dashboard, drill into detail on dedicated screens
- **Role-optimized:** Each stakeholder sees only the navigation that matters to them
- **Consistent shell pattern:** All roles share the PremiumShell layout (nav rail / bottom nav / content area)
- **Context-aware:** Tab state preserved when switching, clean state when deep-linking

---

## Player Navigation

### Phone (Bottom Navigation + Stack)

```
┌─────────────────────────────────┐
│         Player Shell            │
│  ┌───────────────────────────┐  │
│  │      Content Area         │  │
│  │  (IndexedStack — tabs     │  │
│  │   preserve scroll state)  │  │
│  │                           │  │
│  │                           │  │
│  │                           │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Home  │ Perf  │ AI  │ Chat │  │
│  │       │       │Coach│      │  │
│  └───────────────────────────┘  │
│  More in drawer:                │
│  • Community                     │
│  • Coaches                       │
│  • Squad Goals                   │
│  • Profile                       │
└─────────────────────────────────┘
```

**Bottom Nav (5 items):**
1. **Home** — Dashboard (KPIs, upcoming session, quick actions, performance preview, coach carousel, community preview, activity timeline)
2. **Performance** — Charts, metric logging, session history
3. **AI Coach** — Video analysis upload and results
4. **Chat** — Message list
5. *(overflow in drawer)*

**Drawer / More menu:**
| Item | Screen |
|------|--------|
| Community | Community feed |
| Coaches | Coach discovery and booking |
| Squad Goals | Team goal tracking |
| Profile | Edit profile, settings, help |

**Dashboard (Home) layout:**
```
┌─────────────────────────────────┐
│ Header: Greeting, Name, Quote   │
│ Avatar with level/rank pills    │
│ XP progress bar                 │
├─────────────────────────────────┤
│ Overview section title          │
│ [KPI] [KPI]                     │
│ [KPI] [KPI]                     │
├─────────────────────────────────┤
│ Quick Actions (2×2 grid)        │
│ Book Coach │ Community          │
│ Performance│ Sessions           │
├─────────────────────────────────┤
│ Performance Trend (chart card)  │
│ [Chart]                         │
├─────────────────────────────────┤
│ Upcoming Session (card)         │
│ Title, Sport, Date, Time, Venue │
│ [View Details] [Reschedule]     │
├─────────────────────────────────┤
│ Find a Coach (horizontal scroll)│
│ [Coach] [Coach] [Coach]         │
├─────────────────────────────────┤
│ Achievements (horizontal scroll)│
│ [Badge] [Badge] [Badge] [Badge] │
├─────────────────────────────────┤
│ Community Preview               │
│ User activity cards             │
├─────────────────────────────────┤
│ Recent Activity (timeline)      │
│ • Session completed             │
│ • Metric logged                 │
│ • Achievement unlocked          │
└─────────────────────────────────┘
```

---

### Tablet (Side Nav + Adaptive Content)

```
┌──────────────────────────────────────────┐
│  ┌────────┐  ┌────────────────────────┐  │
│  │  Nav   │  │      Content Area      │  │
│  │  Rail  │  │                        │  │
│  │        │  │                        │  │
│  │ 🏠 Home│  │                        │  │
│  │ 📊 Perf│  │  Side-by-side layout:  │  │
│  │ 🤖 AI  │  │  [Chart]  [Scores]     │  │
│  │ 💬 Chat│  │  4-col KPI grid        │  │
│  │ 👥 Comm│  │  2-col action grid     │  │
│  │ 👨‍🏫 Coaches│  │  Horizontal coach cards │  │
│  │ 🏆 Goals│  │                        │  │
│  │ 👤 Prof│  │                        │  │
│  └────────┘  └────────────────────────┘  │
└──────────────────────────────────────────┘
```

**Nav rail features:**
- Icons + labels for all 8 nav items
- Active state highlight
- Collapsible to icon-only on narrower tablets

---

### Desktop (Sidebar + Expansive Content)

```
┌──────────────────────────────────────────────────────┐
│  ┌────────────┐  ┌────────────────────────────────┐  │
│  │  Sidebar   │  │         Content Area            │  │
│  │  (240px)   │  │                                 │  │
│  │            │  │  Grid layouts:                  │  │
│  │  🏠 Home   │  │  [KPI][KPI][KPI][KPI]          │  │
│  │  📊 Perf   │  │  [Quick Actions × 4 row]        │  │
│  │  🤖 AI     │  │  [Chart 60%] [Scores 40%]       │  │
│  │  💬 Chat   │  │  [Session Card full width]       │  │
│  │  👥 Comm   │  │  [Coach Carousel]               │  │
│  │  👨‍🏫 Coaches│  │  [Achievement Badges]           │  │
│  │  🏆 Goals  │  │  [Activity Timeline]             │  │
│  │  👤 Prof   │  │                                 │  │
│  │            │  │                                 │  │
│  │  User info │  │                                 │  │
│  │  at bottom │  │                                 │  │
│  └────────────┘  └────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

## Coach Navigation

### Phone (Bottom Nav)

| Tab | Screen |
|-----|--------|
| Home | Dashboard (KPIs, upcoming sessions, students, earnings) |
| Schedule | Session calendar, create session |
| Students | Student list with profiles and progress |
| Earnings | Earnings chart, payout history, subscription |
| Profile | Edit profile, rates, availability, settings |

### Tablet (Nav Rail)

Same items as phone but with nav rail showing all tabs.

### Desktop (Sidebar)

Sidebar with all coach items + quick stats at bottom.

---

## Academy Navigation

### Phone (Bottom Nav)

| Tab | Screen |
|-----|--------|
| Home | Dashboard (students, coaches, batches, placements) |
| Batches | Batch management, coach assignment |
| Coaches | Coach profiles, performance, placement |
| Jobs | Job postings, applicant tracking |
| More | Marketing, coupons, reports, settings |

### Tablet / Desktop

Nav rail / sidebar with all academy functions.

---

## Parent Navigation

### Phone (Bottom Nav)

| Tab | Screen |
|-----|--------|
| Home | Child overview, upcoming sessions, recent activity |
| Progress | Performance charts, attendance, achievements |
| Coach | Coach communication, feedback history |
| Payments | Fee history, contracts, payment methods |
| Profile | Manage children, notification preferences, settings |

---

## Venue Owner Navigation

### Phone (Bottom Nav)

| Tab | Screen |
|-----|--------|
| Home | Utilization KPIs, today's bookings |
| Bookings | Booking calendar, manage requests |
| Venue | Venue profile, photos, pricing, availability |
| Earnings | Revenue, payout history |
| Profile | Settings, notifications, support |

---

## Admin Navigation

### Phone (Bottom Nav)

| Tab | Screen |
|-----|--------|
| Home | System KPIs, active users, revenue |
| Users | User management, roles, bans |
| Reports | Analytics, financial reports, growth |
| Content | Community moderation, reported content |
| Settings | Feature flags, config, support |

---

## GoRouter Route Map

| Route | Screen | Auth Required | Notes |
|-------|--------|---------------|-------|
| `/` | SplashScreen | No | Auto-redirects based on auth state |
| `/login` | LoginScreen | No | |
| `/signup` | SignupScreen | No | |
| `/forgot-password` | ForgotPasswordScreen | No | |
| `/home` | RoleRouter | Yes | Routes to correct shell by role |
| `/venues` | VenueDiscoveryScreen | Yes | |
| `/venues/:id` | VenueDetailScreen | Yes | |
| `/chat` | ChatListScreen | Yes | |
| `/chat/:id` | ChatDetailScreen | Yes | extra: otherUserId |
| `/coach-discovery` | CoachDiscoveryScreen | Yes | Also available as shell tab |
| `/create-session` | CreateSessionScreen | Yes | Coach only |
| `/contracts` | ContractListScreen | Yes | |
| `/contracts/:id` | ContractDetailScreen | Yes | |

---

## Navigation Rules

1. **Tab state preservation:** Shell uses IndexedStack — switching tabs preserves scroll position and state
2. **Deep link routing:** GoRouter routes open as full-screen pages on top of the shell
3. **Back navigation:** Deep-linked screens show back button and return to the originating shell context
4. **Auth redirect:** Unauthenticated users are redirected to `/login` from any protected route
5. **Role enforcement:** RoleRouter checks `UserModel.role` and routes to the correct shell. Any role-mismatched navigation redirects to the home shell
6. **Bottom nav overflow:** On phone, a 5th+ tab is shown via a "More" menu or drawer, never via a scrollable bottom nav (prevents usability issues)
