# Gamification System: Complete Design

---

## Philosophy

SportsEco's gamification is not about addictive hooks. It is about creating meaningful progression loops that mirror real athletic development. Every game mechanic maps to a real-world action that improves the player, the coach, the academy, or the ecosystem.

Core principle: **Points represent progress. Levels represent mastery. Achievements represent moments. Squad goals represent community.**

---

## Player Progression System

### Experience Points (XP)

#### Earning XP

| Action | XP Awarded | Frequency Limit | Rationale |
|---|---|---|---|
| Complete a coaching session | 25 | Per session | Shows commitment |
| Upload video for analysis | 15 | Per video | Self-improvement |
| Achieve pose score > 80 on analysis | 20 | Per video | Quality of practice |
| Log a performance metric | 5 | Per metric, 10/day | Tracking habit |
| Win a tournament match | 50 | Per match | Competitive success |
| Complete a squad goal | 100 | Per goal | Teamwork |
| Join a squad goal | 10 | Per goal | Initiative |
| Log in daily (streak bonus) | 5 + streak_bonus | Once daily | Consistency |
| Refer a new user | 100 | Per referral | Ecosystem growth |
| Leave a coach review | 10 | Per review, 1/coach | Community contribution |
| Rate a venue | 5 | Per venue | Data contribution |
| Complete daily mission | 30 | Per mission | Engagement |
| Complete weekly challenge | 150 | Per week | Dedication |
| Complete monthly goal | 500 | Per month | Long-term commitment |
| Share a post in community | 10 | 3/day | Social engagement |
| Get a like on your post | 2 | 50/day max | Positive contribution |

#### Spending XP

XP is a measure of achievement, not currency. It is not spent. It accumulates to determine level and rank.

### Levels System (Existing - Enhanced)

```
Level 1:  Rookie     (0-100 XP)     Icon: 🥚
Level 2:  Amateur    (101-300 XP)   Icon: 🌱
Level 3:  Contender  (301-600 XP)   Icon: ⚡
Level 4:  Champion   (601-1000 XP)  Icon: 🏆
Level 5:  Legend     (1001-2000 XP) Icon: 👑
Level 6:  Mythic     (2001-5000 XP) Icon: 🌟

NEW Levels (to add):
Level 7:  Immortal   (5001-10000 XP)  Icon: ⚔️
Level 8:  Godlike    (10001-20000 XP) Icon: 🔥
Level 9:  Ascended   (20001-50000 XP) Icon: ✨
Level 10: GOAT       (50000+ XP)      Icon: 🐐
```

#### Level-Up Rewards

| Level | Reward |
|---|---|
| Rookie -> Amateur | Profile badge unlocked |
| Amateur -> Contender | 1 free session credit |
| Contender -> Champion | Special profile border |
| Champion -> Legend | Priority coach matching |
| Legend -> Mythic | Exclusive tournament access |
| Mythic -> Immortal | "Verified Athlete" badge |
| Immortal -> Godlike | Free premium month |
| Godlike -> Ascended | 1-on-1 with pro coach |
| Ascended -> GOAT | Hall of Fame feature |

### Rank System (Existing - Enhanced)

```
Rank 1: Bronze    🥉  (0-200 XP in current level)
Rank 2: Silver    🥈  (201-400 XP)
Rank 3: Gold      🥇  (401-600 XP)
Rank 4: Platinum  💎  (601-800 XP)
Rank 5: Diamond   🔷  (801-1000 XP)

NEW Ranks:
Rank 6: Elite     🌟  (1001-1200 XP)
Rank 7: Supreme   👑  (1201-1500 XP)

Rank progress resets at each level (soft reset).
A player at "Champion II" is Level 4, Rank 2.
```

### Combined Display

Player profile shows: `Level 4 - Champion | Rank 2 - Silver`
Or visually: `🏆 Champion II`

---

## Achievement System

### Current Achievements

| ID | Title | Description | Points | Status |
|---|---|---|---|---|
| first_win | First Victory | Win your first tournament match | 10 | EXISTS |
| streak_5 | On Fire | Win 5 matches in a row | 50 | EXISTS |
| champion_10 | Champion Material | Win 10 championship titles | 100 | EXISTS |
| coach_hired | Team Up | Hire your first personal coach | 20 | EXISTS |
| venue_explorer | Explorer | Visit 5 different venues | 30 | EXISTS |
| social_butterfly | Social Butterfly | Connect with 10 other players | 40 | EXISTS |

### New Achievements (To Add)

#### Training & Performance

| ID | Title | Description | XP | Criteria |
|---|---|---|---|---|
| first_session | First Step | Complete your first coaching session | 15 | 1 session attended |
| decicated_10 | Getting Serious | Complete 10 sessions | 50 | 10 sessions |
| centurion | Century | Complete 100 sessions | 200 | 100 sessions |
| marathon_athlete | Marathon Athlete | Complete 500 sessions | 500 | 500 sessions |
| perfect_form | Perfect Form | Get 3 videos with 90+ pose score | 75 | 3 analyses >= 90 |
| improved_self | Growth Mindset | Improve pose score by 20 points | 60 | Pose score delta >= 20 |
| metric_tracker | Data Driven | Log 100 performance metrics | 40 | 100 metrics logged |
| all_rounder | All Rounder | Log metrics in all 4 categories | 30 | Speed, duration, distance, accuracy |

#### Community & Social

| ID | Title | Description | XP | Criteria |
|---|---|---|---|---|
| first_post | First Post | Share your first community post | 10 | 1 post |
| influencer | Influencer | Get 100 total likes on posts | 50 | 100 cumulative likes |
| helpful | Helpful | Leave 10 coach reviews | 40 | 10 reviews |
| networker | Networker | Chat with 20 different users | 60 | 20 unique chat partners |
| squad_player | Team Player | Join 5 squad goals | 75 | 5 squad goal memberships |
| goal_champion | Goal Champion | Complete 3 squad goals | 150 | 3 squad goals completed |
| top_contributor | Top Contributor | Be top contributor on a squad goal | 50 | Highest contribution in a goal |

#### Coaching (Player Perspective)

| ID | Title | Description | XP | Criteria |
|---|---|---|---|---|
| coach_hopper | Explorer | Train with 5 different coaches | 50 | 5 unique coaches |
| loyal | Loyal | Stick with 1 coach for 20 sessions | 100 | 20 sessions same coach |
| first_tournament | Competitor | Participate in first tournament | 40 | Tournament attendance |
| champion | Champion | Win a championship | 100 | Championship win |
| dynasty | Dynasty | Win 5 championships | 300 | 5 championship wins |

#### Milestone (Player Level-Based)

| ID | Title | Description | XP | Criteria |
|---|---|---|---|---|
| level_5 | Rising Star | Reach Level 5 (Legend) | 100 | Level >= 5 |
| level_8 | Elite Athlete | Reach Level 8 (Godlike) | 250 | Level >= 8 |
| level_10 | Living Legend | Reach Level 10 (GOAT) | 1000 | Level >= 10 |

#### Streak Achievements

| ID | Title | Description | XP | Criteria |
|---|---|---|---|---|
| streak_3 | Getting Consistent | 3-day login streak | 15 | 3 consecutive days |
| streak_7 | Week Warrior | 7-day login streak | 50 | 7 consecutive days |
| streak_14 | Fortnight Focus | 14-day login streak | 120 | 14 consecutive days |
| streak_30 | Monthly Dedication | 30-day login streak | 300 | 30 consecutive days |
| streak_100 | Iron Will | 100-day login streak | 1000 | 100 consecutive days |

### Achievement Categories

```
🏅 PERFORMANCE (form, metrics, improvement)
🎯 TRAINING (sessions, attendance, dedication)
🤝 SOCIAL (community, reviews, chat, referrals)
👥 TEAM (squad goals, collaboration)
🏆 COMPETITION (tournaments, wins, championships)
🔥 STREAK (consistency, login streaks)
⭐ MILESTONE (level-based progression)
```

Each category has its own visual badge style and color scheme.

---

## Daily Streak System (New)

### Structure

| Day Range | Bonus XP | Label |
|---|---|---|
| 1-2 | 5 | Warm Up |
| 3-6 | 10 | Getting Started |
| 7-13 | 20 | Week Warrior |
| 14-29 | 35 | Fortnight Focus |
| 30-59 | 60 | Monthly Dedication |
| 60-99 | 100 | Veteran |
| 100+ | 200 | Legendary |

### Streak Visual
- Flame icon that grows from small (day 1) to large (day 100+)
- Color shifts: gray -> orange -> red -> purple -> gold
- Progress ring showing days completed this week
- "Streak Saver" item (future monetization: 1 free streak freeze per month for premium)

### Streak Reset
- Missing a full calendar day (midnight to midnight) resets streak to 0
- Weekend skip allowed with "Streak Freeze" (premium feature)
- Manual streak repair not allowed (maintains integrity)

---

## Weekly Missions (New)

Every Monday, 5 missions are generated per player. Complete them by Sunday midnight.

| Mission | XP | Difficulty |
|---|---|---|
| Complete 3 coaching sessions this week | 30 | Easy |
| Upload 2 videos for analysis | 25 | Easy |
| Log metrics on 5 different days | 20 | Easy |
| Join a new squad goal | 15 | Easy |
| Leave 2 coach reviews | 20 | Easy |
| Train with 2 different coaches | 40 | Medium |
| Improve pose score by at least 5 points | 50 | Medium |
| Contribute 10 units to a squad goal | 35 | Medium |
| Get 10 likes on your community posts | 30 | Medium |
| Complete 5 sessions | 45 | Medium |
| Win a tournament match | 60 | Hard |
| Complete 7 sessions (full week) | 80 | Hard |
| Achieve 90+ pose score on a video | 70 | Hard |
| Be top contributor on a squad goal | 65 | Hard |
| Get 50 likes across all posts | 100 | Hard |

Missions are personalized based on the player's sport, level, and activity history.

---

## Monthly Goals (New)

| Goal | XP | Description |
|---|---|---|
| Session King | 300 | Complete 20+ sessions in a month |
| Form Master | 250 | Average pose score > 75 across all videos |
| Social Star | 200 | Get 100+ likes across all posts |
| Goal Crusher | 250 | Complete 5 squad goals |
| Metric Mania | 150 | Log 200+ metrics |
| Streak Holder | 500 | Maintain 30-day streak through the month |
| All Rounder | 400 | Complete at least 5 missions in each category |

Monthly goals are shown at the start of each month with progress tracking.

---

## Coach Reputation System

### Reputation Points

| Action | Points | Limit |
|---|---|---|
| Complete a session | +2 | Per session |
| Get a 5-star rating | +10 | Per review |
| Get a 4-star rating | +5 | Per review |
| Receive positive review text | +3 | Per review |
| Achieve 100 sessions | +50 | One-time |
| Achieve 500 sessions | +200 | One-time |
| Get academy placement | +100 | Per placement |
| Complete subscription month | +20 | Per month |
| Refer another coach | +50 | Per referral |
| Post helpful content | +15 | Per post |

### Coach Reputation Tiers

| Tier | Points Needed | Badge | Benefits |
|---|---|---|---|
| Bronze Coach | 0 | 🟤 | Standard listing |
| Silver Coach | 500 | ⚪ | Priority in search |
| Gold Coach | 2000 | 🟡 | "Recommended" badge |
| Platinum Coach | 5000 | 🔵 | Featured in carousel |
| Diamond Coach | 10000 | 💎 | Verified Pro badge, top placement |

### Coach Rating Display

```
⭐⭐⭐⭐☆  4.2 (127 reviews)
Gold Coach 🟡
```

---

## Academy Rating System

### Reputation Points

| Action | Points | Limit |
|---|---|---|
| Enroll a student | +5 | Per student |
| Place a coach | +10 | Per placement |
| Complete a batch session | +1 | Per session |
| Run a campaign | +20 | Per campaign |
| Get verified | +100 | One-time |
| Coach positive rating (affiliated) | +3 | Per period |
| Student achievement | +2 | Per achievement |

### Academy Reputation Tiers

| Tier | Points | Badge | Visibility |
|---|---|---|---|
| Local | 0 | - | Standard |
| Rising | 1000 | 📈 | Boosted in local search |
| Notable | 5000 | ⭐ | Featured in city |
| Premier | 20000 | 🏆 | Featured in region |
| Elite | 50000 | 👑 | Top placement, verified badge |

---

## Season System (Future)

### Structure
- Each season = 3 months (Quarterly)
- 4 seasons per year: Spring, Summer, Fall, Winter
- Seasonal reset: Leaderboard resets, new achievements available
- Season Pass: Free + Premium track

### Season Rewards
| Reward Type | Free Track | Premium Track |
|---|---|---|
| Avatar Border | Per season | Per season + exclusive |
| Title | - | Seasonal title (e.g., "Summer Champion 2026") |
| XP Bonus | 1.0x | 1.5x |
| Streak Freeze | 0 | 3 per season |
| Exclusive Badge | - | 1 per season |
| Season Loot Box | - | 1 per level milestone |

### Season Pass Pricing
- Free: Included for all users
- Premium: Rs. 299/season or Rs. 999/year

---

## Leaderboards (New - To Build)

### Types

| Leaderboard | Scope | Refresh | Criteria |
|---|---|---|---|
| City Rankings | City-wide | Daily | Total XP |
| Sport Rankings | City-wide per sport | Daily | Sport-specific XP |
| Academy Rankings | City-wide | Weekly | Academy reputation |
| Coach Rankings | City-wide per sport | Weekly | Coach rating + reputation |
| Squad Goal | Goal-specific | Real-time | Contribution units |
| Weekly Challenge | Platform-wide | Weekly | Weekly mission completion |
| Season Leaderboard | Platform-wide | Seasonal | Season XP total |

### Leaderboard Display
```
#1  🥇 Rahul Sharma     Legend III     12,450 XP
#2  🥈 Priya Patel      Champion V     11,200 XP
#3  🥉 Arjun Singh      Champion III   10,800 XP
#4     Sneha Rao        Champion II    10,100 XP
#5     Vikram Joshi     Legend I        9,850 XP
```

---

## Notification Triggers for Gamification

| Event | Notification | Channel |
|---|---|---|
| Level up | "Congrats! You reached {level} - {title}!" | Push + In-app |
| Achievement unlocked | "Achievement unlocked: {title}" | Push + In-app |
| Streak milestone | "{n}-day streak! Keep going!" | Push |
| Weekly mission available | "5 new missions ready this week" | Push (Monday) |
| Squad goal completed | "Goal completed! +{n} XP" | Push |
| Season pass reward | "Season reward available: {reward}" | In-app |
| Rank up | "You reached {rank} rank!" | In-app |
| Coach rating received | "New review: {n} stars" | Push |
| Leaderboard position changed | "You moved to #{n} in {city}" | Push (weekly) |

---

## Implementation Architecture

### Firebase Collections
```
playerAchievements/{auto-id}
  playerId: string
  achievementId: string
  unlockedAt: timestamp
  metadata: map? (e.g., videoId for form achievements)

playerStreaks/{auto-id}
  playerId: string
  currentStreak: int
  longestStreak: int
  lastLoginDate: timestamp
  streakFrozenDates: timestamp[]

playerMissions/{auto-id} (weekly)
  playerId: string
  weekStart: timestamp
  missions: [{missionId, description, xp, current, target, completed}]
  completedCount: int

monthlyGoals/{auto-id}
  playerId: string
  month: string (YYYY-MM)
  goals: [{goalId, description, xp, current, target}]
  completed: boolean

leaderboards/{leaderboardId}
  type: string (city/sport/coach/academy)
  scope: string (city name / sport name)
  season: string? (YYYY-Qn)
  entries: [{rank, userId, score, name, photoUrl}]
  updatedAt: timestamp
```

### Cloud Functions Needed
1. `onPlayerSessionComplete` - Award XP, check achievements
2. `onDailyLogin` - Update streak, award streak XP
3. `onWeeklyReset` - Generate weekly missions, archive old ones
4. `onMonthlyReset` - Generate monthly goals
5. `onSeasonEnd` - Calculate season rewards, reset leaderboards
6. `recaculateLeaderboards` - Periodic leaderboard rebuild
7. `checkAchievements` - Check and unlock achievements on relevant events

### Riverpod Providers Needed (New)
```
streakProvider(playerId) -> Stream<StreakData>
weeklyMissionsProvider(playerId) -> Stream<List<Mission>>
monthlyGoalsProvider(playerId) -> Stream<List<MonthlyGoal>>
leaderboardProvider(type, scope) -> Stream<Leaderboard>
seasonPassProvider(playerId) -> Stream<SeasonPassData>
```
