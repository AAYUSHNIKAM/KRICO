# Screen Inventory: Complete Screen Audit

---

## Legend

| Status | Meaning |
|---|---|
| **EXISTS** | Implemented and functional |
| **PARTIAL** | Basic UI exists, missing key functionality |
| **REDESIGN** | Needs UX/UI redesign |
| **REBUILD** | Needs complete code rewrite |
| **MISSING** | Not yet implemented |
| **FUTURE** | Planned for later phases |

Priority: P0 (Critical), P1 (High), P2 (Medium), P3 (Low)

---

## Auth Screens

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Splash Screen | `features/auth/presentation/splash_screen.dart` | EXISTS | P0 | Animated brand splash |
| Login Screen | `features/auth/presentation/login_screen.dart` | EXISTS | P0 | Email/password + Google sign-in |
| Signup Screen | `features/auth/presentation/signup_screen.dart` | EXISTS | P0 | 3-step: Role -> Personal -> Credentials |
| Forgot Password | `features/auth/presentation/forgot_password_screen.dart` | EXISTS | P0 | Email-based reset |
| Phone OTP Login | MISSING | P1 | Needed for India market reach |
| Onboarding Walkthrough | MISSING | P1 | First-launch tutorial |
| Coach Profile Setup | MISSING | P1 | Post-signup onboarding for coaches |
| Academy Profile Setup | MISSING | P1 | Post-signup onboarding for academies |
| Player Profile Setup | MISSING | P1 | Post-signup for players |
| Parent Child Linking | MISSING | P1 | Add children post-signup |

## Dashboards

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Player Dashboard | `features/player/presentation/dashboard/dashboard_page.dart` | REDESIGN | P0 | Functionally complete but uses new design system partially. Rich widget composition: header, KPI, quick actions, performance, sessions, coach carousel, achievements, community, timeline |
| Coach Dashboard | `features/coach/presentation/coach_dashboard.dart` | REDESIGN | P0 | Uses old theme imports (core/theme), needs migration to design_system. Very feature-rich (985 lines) |
| Academy Dashboard | `features/academy/presentation/academy_dashboard.dart` | REDESIGN | P0 | Same theme migration issue. Stats, batches, advertising, placements |
| Parent Dashboard | `features/home/presentation/parent_dashboard.dart` | REDESIGN | P0 | Same theme migration issue. Multi-player overview, metric logging |
| Admin Dashboard | `features/admin/presentation/admin_dashboard.dart` | REDESIGN | P0 | Same theme migration issue. Platform overview, venue form, coupon management |
| Venue Partner Dashboard | MISSING | P1 | New role dashboard needed |

## Role Shells (Layout Containers)

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Player Shell | `features/home/presentation/player_shell.dart` | EXISTS | P0 | Uses PremiumShell |
| Coach Shell | `features/home/presentation/coach_shell.dart` | EXISTS | P0 | Uses PremiumShell |
| Academy Shell | `features/home/presentation/academy_shell.dart` | EXISTS | P0 | Uses PremiumShell |
| Parent Shell | `features/home/presentation/parent_shell.dart` | EXISTS | P0 | Uses PremiumShell |
| Admin Shell | `features/home/presentation/admin_shell.dart` | EXISTS | P0 | Uses PremiumShell |
| Role Router | `features/home/presentation/role_router.dart` | EXISTS | P0 | Routes based on UserRole |

## Venues

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Venue Discovery | `features/venue/presentation/venue_discovery_screen.dart` | EXISTS | P0 | List view of venues |
| Venue Detail | `features/venue/presentation/venue_detail_screen.dart` | EXISTS | P0 | Full venue info |
| Venue Map View | MISSING | P1 | Map integration needed |
| Venue Booking Calendar | MISSING | P1 | Slot selection |
| Venue Partner Management | MISSING | P1 | Dashboard for venue partners |
| Venue Add/Edit (Admin) | EXISTS (in Admin Dashboard) | P0 | Form in admin dashboard |

## Coaching & Sessions

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Coach Discovery | `features/home/presentation/coach_discovery_screen.dart` | EXISTS | P0 | Coach listings |
| Coach Profile View | PARTIAL (within discovery) | P1 | Needs dedicated detail screen |
| Create Session | `features/coach/presentation/create_session_screen.dart` | EXISTS | P0 | Session creation form |
| Schedule Tab (Coach) | `features/home/presentation/schedule_tab.dart` | EXISTS | P0 | Coach's session calendar |
| Students Tab (Coach) | `features/home/presentation/students_tab.dart` | EXISTS | P0 | Coach's student list |
| Session Detail | MISSING | P1 | Need dedicated session view |
| Session Booking (Player) | MISSING | P1 | Booking request flow |
| Session History | PARTIAL (in dashboards) | P1 | Need dedicated history screen |

## Academy

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Batches Tab | `features/home/presentation/batches_tab.dart` | EXISTS | P0 | Academy batch management |
| Academy Coaches Tab | `features/home/presentation/academy_coaches_tab.dart` | EXISTS | P0 | Coach management |
| Advertising Tab | `features/home/presentation/advertising_tab.dart` | EXISTS | P0 | Campaign management |
| Academy Jobs Tab | `features/home/presentation/academy_jobs_tab.dart` | EXISTS | P0 | Job management |
| Coach Academy Jobs | `features/home/presentation/coach_academy_jobs_screen.dart` | EXISTS | P0 | Coach view of jobs |
| Student Enrollment | MISSING | P1 | Enroll students in batches |
| Batch Detail | MISSING | P1 | Full batch view with roster |

## Chat

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Chat List | `features/chat/presentation/chat_list_screen.dart` | EXISTS | P0 | Conversation list |
| Chat Detail | `features/chat/presentation/chat_detail_screen.dart` | EXISTS | P0 | Message thread |
| Create Chat | PARTIAL (in ChatService) | P1 | UI for starting new chat |

## Contracts

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Contract List | `features/contracts/presentation/contract_list_screen.dart` | EXISTS | P0 | User's contracts |
| Contract Detail | `features/contracts/presentation/contract_detail_screen.dart` | EXISTS | P0 | Single contract view |
| Contract Creation Flow | MISSING | P1 | Multi-step contract creation |
| Contract Signing | PARTIAL (in service) | P1 | Digital signature UI |
| Contract Terms Editor | MISSING | P2 | Template-based terms |

## Video Analysis

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Video Analysis | `features/video_analysis/presentation/video_analysis_screen.dart` | EXISTS | P0 | Upload, view results, history |
| Coach Video Review | PARTIAL (in service) | P1 | Coach feedback UI |
| Video Recording (in-app) | MISSING | P2 | Camera capture |
| Video Comparison | MISSING | P2 | Side-by-side analysis |

## Squad Goals

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Squad Goals List | `features/squad_goals/presentation/squad_goals_screen.dart` | EXISTS | P0 | Active goals with progress |
| Create Squad Goal | PARTIAL (bottom sheet) | P0 | Modal form |
| Goal Detail | MISSING | P1 | Expanded goal view |

## Community

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Community Feed | `features/community/presentation/community_screen.dart` | EXISTS | P0 | Social feed with mock posts |
| Create Post | PARTIAL | P0 | Text only, media buttons non-functional |
| User Profile in Feed | PARTIAL | P1 | Limited user display |
| Post Detail | MISSING | P2 | Expanded post view |

## Performance & Analytics

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Performance Tab (Player) | `features/home/presentation/performance_tab.dart` | EXISTS | P0 | Player metrics |
| Earnings Tab (Coach) | `features/home/presentation/earnings_tab.dart` | EXISTS | P0 | Income overview |
| Parent Progress | `features/home/presentation/parent_progress_screen.dart` | EXISTS | P0 | Child progress |
| Achievement Tab | `features/home/presentation/achievement_tab.dart` | EXISTS | P0 | Achievement display |
| Performance Charts | MISSING | P1 | Visual trend charts |
| Coach Reports | MISSING | P2 | Detailed performance reports |

## Admin

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Users Tab | `features/home/presentation/users_tab.dart` | EXISTS | P0 | All users list |
| Coupons Tab | `features/home/presentation/coupons_tab.dart` | EXISTS | P0 | Coupon management |
| Content Moderation | MISSING | P2 | Report review system |
| System Health | MISSING | P2 | Platform monitoring |

## Shared / Core

| Screen | File | Status | Priority | Notes |
|---|---|---|---|---|
| Profile Page | `core/widgets/profile_page.dart` | EXISTS | P0 | User profile |
| Loading Shimmer | `core/widgets/loading_shimmer.dart` | EXISTS | P0 | Shimmer states |
| App Scaffold | `core/widgets/app_scaffold.dart` | EXISTS | P0 | Base scaffold |
| Glass Morphism | `core/widgets/glass_morphism.dart` | EXISTS | P1 | Glass card effect |
| Section Header | `core/widgets/section_header.dart` | EXISTS | P0 | Section titles |
| Gradient Button | `core/widgets/gradient_button.dart` | EXISTS | P0 | Styled buttons |
| Stats Card | `core/widgets/stats_card.dart` | EXISTS | P0 | Metric display |
| Error Handler | PARTIAL (in shells) | P1 | Global error boundary |
| Network Status | MISSING | P1 | Offline indicator |
| Deep Link Handler | MISSING | P2 | External linking |

## Design System Screens (No dedicated screen, reusable components)

| Component | File | Status | Priority |
|---|---|---|---|
| Premium Shell | `design_system/layouts/premium_shell.dart` | EXISTS | P0 |
| Premium Sidebar | `design_system/layouts/premium_sidebar.dart` | EXISTS | P0 |
| Premium Drawer | `design_system/layouts/premium_drawer.dart` | EXISTS | P0 |
| Premium Top Bar | `design_system/layouts/premium_top_bar.dart` | EXISTS | P0 |
| Bottom Nav | `design_system/layouts/bottom_nav.dart` | EXISTS | P0 |
| Collapsed Sidebar | `design_system/layouts/collapsed_sidebar.dart` | EXISTS | P0 |
| Mobile Drawer | `design_system/layouts/mobile_drawer.dart` | EXISTS | P0 |
| Floating Nav | `design_system/layouts/floating_nav.dart` | EXISTS | P0 |
| Nav Rail | `design_system/layouts/nav_rail.dart` | EXISTS | P0 |
| Glass Card | `design_system/widgets/surfaces/glass_card.dart` | EXISTS | P1 |
| App Card | `design_system/widgets/surfaces/app_card.dart` | EXISTS | P0 |
| Shimmer Widget | `design_system/widgets/surfaces/shimmer_widget.dart` | EXISTS | P0 |
| Empty State | `design_system/widgets/misc/empty_state_widget.dart` | EXISTS | P0 |
| Badge Widget | `design_system/widgets/misc/badge_widget.dart` | EXISTS | P0 |
| Avatar Widget | `design_system/widgets/misc/avatar_widget.dart` | EXISTS | P0 |
| Pill Widget | `design_system/widgets/misc/pill_widget.dart` | EXISTS | P0 |
| Tab Bar Widget | `design_system/widgets/misc/tab_bar_widget.dart` | EXISTS | P0 |
| Primary Button | `design_system/widgets/buttons/primary_button.dart` | EXISTS | P0 |
| Secondary Button | `design_system/widgets/buttons/secondary_button.dart` | EXISTS | P0 |
| Glass Button | `design_system/widgets/buttons/glass_button.dart` | EXISTS | P1 |

## Missing Screens Summary (Priority Order)

| Screen | Priority | Reason |
|---|---|---|
| Coach Profile Detail | P1 | Needed for booking decision |
| Session Detail | P1 | View full session info |
| Session Booking Flow | P1 | Core transaction flow |
| Venue Booking Calendar | P1 | Enable venue bookings |
| Venue Partner Dashboard | P1 | New role enablement |
| Phone OTP Login | P1 | India market requirement |
| Onboarding Walkthrough | P1 | Reduce user drop-off |
| Post-Signup Profile Setup (all roles) | P1 | Complete onboarding |
| Notifications Center | P1 | Display push notifications in-app |
| Payment Gateway Integration | P1 | Enable real payments |
| Offline/Network Status | P1 | Improve reliability |
| Goal Detail View | P1 | Expanded squad goal view |
| Performance Charts | P1 | Visual data representation |
| Coach Video Review Screen | P1 | Coach review workflow |
| Student Enrollment | P1 | Academy batch enrollment |
| Contract Creation Flow | P1 | Guided contract creation |
| Parent Child Linking | P1 | Multi-child management |
| In-App Camera Recording | P2 | Native video capture |
| Video Comparison | P2 | Before/after analysis |
| Leaderboards | P2 | Competitive rankings |
| Tournament Management | P3 | Events and competitions |
| Content Moderation | P2 | Admin review system |
| Advanced Analytics | P3 | Business intelligence |
