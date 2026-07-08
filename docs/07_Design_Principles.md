# 07 — Design Principles

## Design Philosophy

SportsEco is a premium sports platform, not a booking app, not a social network, not an ERP. The design communicates performance, trust, and growth. Every pixel serves the athlete's journey.

---

## Premium

**What it means:** The app feels like a premium athletic brand — Nike, not a local gym website.

**Rules:**
- Use dark surfaces with subtle gradients as the default theme
- Light theme exists but dark is the hero experience
- Cards have subtle borders and shadows — never flat rectangles
- Gradients are used sparingly for emphasis (headers, primary CTAs, avatar backgrounds)
- Animations are tasteful and purposeful — never gratuitous
- Every screen has a cohesive visual hierarchy, never a wall of text

**What NOT to do:**
- Never use default Material widgets without styling (no raw `ElevatedButton`, `Card`, or `AppBar`)
- Never use pure black (`#000000`) — use `surfaceDark` (near-black with subtle blue tint)
- Never use white text on white backgrounds
- Never mix the two design systems (`core/theme` and `design_system/`) — choose one

---

## Minimal

**What it means:** Show the essential, hide the rest. Every screen prioritizes one primary action.

**Rules:**
- Maximum one primary CTA per screen, one secondary CTA
- Remove all non-essential text. "Learn more" and "Read more" are last resorts
- Empty states guide the user to the next action, not just show an icon
- Forms show only the fields needed for the current step (wizard pattern)
- Navigation has maximum 5 bottom tabs, 8 sidebar items
- Dashboard sections show a preview with a "View All" link — never the full list

**What NOT to do:**
- Never show a screen with more than one scrollable list
- Never show tooltips or coach marks permanently — only on first-time onboarding
- Never use placeholder text like "Lorem ipsum" in production
- Never show raw error codes to users — "Something went wrong" with retry only

---

## Sports-first

**What it means:** The design language draws from sports culture — energy, competition, achievement, movement.

**Rules:**
- Use athletic iconography (trophy, timer, leaderboard, stats, sports equipment)
- Gamification elements (XP bar, level, achievements) are front and center, not buried
- Performance data is presented as stats — numbers are large, bold, and proud
- Competitive elements (leaderboards, ranks, challenges) have visual prominence
- Motion and energy are reflected in animations — quick entrances, sport-like transitions

**What NOT to do:**
- Never treat XP and levels as secondary — they're core to the athlete identity
- Never hide performance data behind multiple taps
- Never use generic icons when sport-specific icons exist

---

## Motion

**What it means:** Animations are fast, fluid, and purposeful. They communicate state changes and guide attention.

**Rules:**
- Entry animations: fade + slide (100–350ms, staggered by index)
- State transitions: 200–300ms, ease-out curves
- Loading states: shimmer skeleton, never spinning indicator for content
- Tab switches: instant (no crossfade — preserves context)
- Pull-to-refresh: subtle haptic-style feedback (visual bounce)

**Animation timing guide:**
| Element | Duration | Curve | Delay |
|---------|----------|-------|-------|
| Page header | 200ms | easeOut | 0ms |
| Dashboard sections | 300–350ms | easeOut | 100–500ms (staggered) |
| List items | 300ms | easeOut | 40–80ms per item |
| Cards | 350ms | easeOut | 200–500ms |
| Buttons (press) | 100ms | easeOut | 0ms |
| Progress bars | 600–800ms | easeOutCubic | 0ms |

**What NOT to do:**
- Never use animations longer than 800ms for UI elements
- Never animate elements that don't change state (static text doesn't need fade-in)
- Never use bouncing or elastic curves — they feel unpolished
- Never animate navigation transitions between shell tabs (only for GoRouter page transitions)

---

## Spacing

**What it means:** Consistent 4px-based spacing scale applied everywhere.

**Scale:**
| Token | Pixels | Usage |
|-------|--------|-------|
| `s2` | 2px | Icon-to-text gap in pills |
| `s4` | 4px | Badge padding, small gaps |
| `s6` | 6px | Tight icon-text spacing |
| `s8` | 8px | Small elements, chip padding, icon gaps |
| `s10` | 10px | Between inline elements |
| `s12` | 12px | Card padding, section spacing |
| `s14` | 14px | Comfortable spacing |
| `s16` | 16px | Standard padding (mobile) |
| `s20` | 20px | Section padding, card inner spacing |
| `s24` | 24px | Section spacing (mobile), desktop padding |
| `s28` | 28px | Desktop section spacing |
| `s32` | 32px | Desktop horizontal padding, large cards |
| `s48` | 48px | Desktop vertical section spacing |

**Rules:**
- Use spacing tokens exclusively — never raw pixel values
- Horizontal padding adapts: mobile = `s16`, tablet = `s24`, desktop = `s32`
- Vertical section spacing: mobile = `s20`/`s24`, desktop = `s28`
- Card internal padding: always `s20` (exception: compact cards = `s12`/`s16`)

**What NOT to do:**
- Never use fractional spacing values (no 13px, 17px)
- Never use `Spacer()` inside cards — use fixed spacing or flex proportion

---

## Cards

**What it means:** Cards are the primary content container — consistent, elevated, and purposeful.

**Card anatomy:**
```
┌─────────────────────────────────┐
│ Accent bar (3px, optional)      │
│ ┌──────────┐                    │
│ │ Icon/    │  Title              │
│ │ Avatar   │  Subtitle           │
│ └──────────┘                    │
│ Content area                    │
│ [--- data / description ---]    │
│ ┌──────────┐ ┌──────────┐      │
│ │ Action 1 │ │ Action 2 │      │
│ └──────────┘ └──────────┘      │
└─────────────────────────────────┘
```

**Rules:**
- Border: 0.5px `border` color
- Border radius: `brXl2` (16px)
- Background: `card` (dark) / `lightCard` (light)
- Inner padding: `s20`
- Cards never have elevation/shadow — use border instead
- Accent bar at top (3px) for emphasis cards (KPI, featured session)
- Card groups use consistent spacing (`s12` gap)

**What NOT to do:**
- Never nest cards inside cards
- Never use different border radius for cards on the same screen
- Never stretch card width beyond 600px on desktop — use max-width
- Never put cards inside `RawScrollbar` or inside horizontal `ListView` without fixed height

---

## Colors

### Dark Theme (Default)

| Token | HEX | Usage |
|-------|-----|-------|
| `surface` | `#0F0F1A` | Page background |
| `surfaceSecondary` | `#1A1A2E` | Elevated surfaces |
| `surfaceMid` | `#16162A` | Secondary backgrounds |
| `surfaceDark` | `#0A0A1A` | Deep backgrounds |
| `card` | `#1E1E32` | Card background |
| `cardDark` | `#15152A` | Card alt background |
| `primary` | `#6C63FF` | Primary actions, links, active states |
| `accent` | `#FF6B6B` | Secondary accent (opposite of primary) |
| `emerald` | `#00D68F` | Success, positive trends, confirmed states |
| `warning` | `#FFAA00` | Warnings, gold elements |
| `danger` | `#FF4757` | Errors, destructive actions |
| `gold` | `#FFD700` | Rank 1, premium badges |
| `purple` | `#7C3AED` | Gamification, achievement elements |
| `orange` | `#FF8C00` | Secondary call-to-action |
| `textPrimary` | `#F0F0F5` | Primary text |
| `textSecondary` | `#A0A0B8` | Secondary text, labels |
| `textTertiary` | `#6B6B85` | Tertiary text, hints |
| `textDim` | `#4A4A6A` | Disabled text, placeholders |
| `border` | `#2A2A45` | Card borders, dividers |
| `divider` | `#1E1E35` | Dividers, progress background |

### Light Theme

Same structural tokens with lighter values (e.g., `lightSurface`, `lightCard`, `lightTextPrimary`, `lightBorder`).

**Rules:**
- Primary color (`#6C63FF`) is the same in both themes for brand consistency
- Gradient arrays used: `gradientPrimary` = [primary, accent variant], `gradientGold` = [warning, orange]
- Background gradients use subtle two-tone (never abrupt color stops)
- Status colors: `emerald` = good, `warning` = attention, `danger` = error

**What NOT to do:**
- Never use color alone to convey status — always include icon or text label
- Never use primary color for background fills (use `withOpacity(0.1-0.2)`)
- Never hardcode colors — always use color tokens

---

## Typography

**Font:** Google Fonts (Inter or similar geometric sans-serif)

**Scale:**
| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `heading1` | 32px | 700 | Page titles, hero numbers |
| `heading2` | 28px | 700 | Section headers (desktop) |
| `heading3` | 24px | 600 | Section headers (mobile) |
| `title2` | 20px | 600 | Card titles, section titles |
| `title3` | 16px | 600 | Card titles, item headers |
| `titleSmall` | 14px | 600 | Small card headers |
| `body` | 14px | 400 | Paragraphs, descriptions |
| `bodyLg` | 16px | 400 | Intro text, quotes |
| `bodySmall` | 12px | 400 | Fine print, captions |
| `caption` | 12px | 500 | Labels, timestamps |
| `captionXs` | 10px | 500 | Tiny labels, badge text |
| `labelSm` | 11px | 600 | Button text (small), filter chips |
| `labelMedium` | 12px | 600 | Form labels |
| `labelLarge` | 14px | 600 | Button text |
| `numericSm` | 24px | 700 | KPI values, stat numbers |
| `priceSmall` | 14px | 700 | Price display |

**Rules:**
- Numeric values use `numericSm` — large, bold, commanding
- Body text never goes below 12px (except `captionXs` at 10px for badges only)
- Line height: body = 1.4, headings = 1.2
- Letter spacing: normal for body, +1.2px for uppercase labels
- Max text width: 600px for readability on desktop

**What NOT to do:**
- Never use more than 2 font weights on a single screen
- Never use italic for body text (reserved for quotes only)
- Never truncate text without `overflow: TextOverflow.ellipsis` and `maxLines`
- Never mix `AppTextStyles` from `core/theme` and `design_system/` in the same feature

---

## Accessibility

**Minimum standards:**
- Touch targets: minimum 44×44px (Material guideline), 48×48px for primary CTAs
- Contrast ratio: minimum 4.5:1 for normal text, 3:1 for large text (18px+)
- All icons must have `Semantics` labels (unless purely decorative with `ExcludeSemantics`)
- All images must have `Semantics` labels describing content
- All form fields must have labels (visible or `Semantics`)
- All progress indicators must expose current value via `Semantics`
- All animated content must respect `MediaQuery.disableAnimations`
- All interactive elements must be keyboard-navigable (desktop)
- Text scaling must be respected — test at 200% font size

**Testing requirements before launch:**
1. Run accessibility scanner (Flutter's built-in or external)
2. Verify all screens with TalkBack (Android) and VoiceOver (iOS)
3. Verify keyboard navigation for all interactive elements on desktop
4. Verify text scaling at 150% and 200% on all primary screens

**What NOT to do:**
- Never use `GestureDetector` without `Semantics` for touch targets
- Never use icons without labels in interactive elements
- Never hardcode font sizes that break at larger accessibility settings

---

## Interaction Philosophy

**Feedback principles:**
1. Every action shows immediate feedback (button press → visual response within 100ms)
2. Every loading state shows a skeleton matching the final layout (never blank or spinner for content)
3. Every error state shows a clear message with a retry action (never raw error codes)
4. Every empty state shows a reason and a suggested next action (never just "No data")
5. Every success state shows a confirmation (snackbar, toast, or inline message)

**Gestures:**
- Tap: primary action
- Long press: secondary actions (edit, delete, share)
- Swipe to dismiss (on list items) — only if action is reversible
- Pull to refresh on all scrollable content screens

**What NOT to do:**
- Never use swipe gestures that conflict with scroll
- Never use long press without visual hint (tooltip or contextual cue)
- Never hide primary actions behind gestures — always visible button first

---

## Responsive Philosophy

**Breakpoints:**
| Range | Device | Columns | Nav |
|-------|--------|---------|-----|
| < 600px | Phone | 1–2 | Bottom nav |
| 600–900px | Small tablet | 2–3 | Bottom nav |
| 900–1200px | Large tablet | 3–4 | Side nav rail |
| > 1200px | Desktop | 4–6 | Full sidebar |

**Adaptation rules:**
1. Navigation shell changes: bottom nav → nav rail → sidebar (not just visibility — different component)
2. Grid columns: 2 on mobile → 3-4 on tablet → 4-6 on desktop
3. Horizontal padding: `s16` → `s24` → `s32`
4. Content max-width: full → 900px centered → 1200px centered
5. Multi-panel layouts: stacked on mobile, side-by-side on desktop

**What NOT to do:**
- Never use `LayoutBuilder` where `MediaQuery` will suffice
- Never hardcode breakpoint values — use responsive helper tokens
- Never stack components on desktop that could be side-by-side (e.g., chart + score card)
- Never use fixed-width containers that overflow on smaller screens

---

## Design Rules — Summary

### DO
- Use dark theme as default
- Use shimmers for loading, not spinners
- Show meaningful empty states
- Animate with purpose (fade + slide, staggered, ≤350ms)
- Use consistent spacing tokens (4px scale)
- Cards with subtle borders, no elevation
- One primary action per screen
- Accessible touch targets (44px+)
- Sport-first visual language

### DON'T
- Use raw Material widgets without styling
- Show "No data" without guidance
- Mix `core/theme` and `design_system/` in the same feature
- Hardcode colors or spacing
- Use color alone for status
- Placeholder or lorem ipsum text
- Nest cards
- Exceed 5 bottom nav items
- Use animations over 800ms
- Skip accessibility semantics
