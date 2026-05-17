# Forma Premium — Feature Spec

> What makes people pay? Removing friction from the journey they're already on.

---

## Philosophy

Premium features in Forma are not paywalled basics. The free tier is genuinely useful — a complete habit tracker with goals, mood, and the activity graph. Premium is for people who are *serious*: they want to understand themselves better, be held accountable harder, and make the app feel truly personal.

**Free tier should make you love the app. Premium should make you feel understood.**

---

## Premium Features (v1 Launch)

### 1. AI Weekly Coach Note
*"Your personal coach, powered by your own data."*

Every Sunday, Forma generates a personalized insight note based on the user's last 7 days — completion patterns, mood correlation, best/worst days, habit streaks at risk. It reads like a letter from a thoughtful mentor, not a dashboard summary.

Implementation:
- On-device computation of stats snapshot
- Sent to Claude API (claude-sonnet) with structured prompt
- Cached locally; regenerated each Sunday or on manual refresh
- Response shown in an editorial card (Fraunces italic, the quote-mark treatment from the prototype)

Why people pay: Generic apps give you numbers. This gives you *meaning*.

---

### 2. Mood × Habit Correlation
*"Do you actually feel better when you meditate? Let's find out."*

A chart that plots mood score (y-axis) against specific habit completion (color/filter). For example: "On days you ran, your average mood was 4.2. On days you didn't, it was 2.9."

UI: A scatter plot or a side-by-side bar comparison per habit. Toggle between habits.

Implementation:
- Computed from `logsBox` + `moodBox` — no server needed
- Minimum 14 days of data to surface (shown as a "keep tracking" placeholder before)

Why people pay: This is the most common question journalers have and never get answered. Pure data, immediate emotional value.

---

### 3. Smart Streak Shield
*"Life happens. Keep your streak."*

Once every 30 days, users can "shield" a streak from breaking — apply it retroactively if they forgot to log, or proactively when they know they'll be traveling. 

Includes a "Vacation Mode" that pauses all habit tracking for a date range without breaking streaks. On return, the streak resumes. 

Implementation: streak state machine aware of shield dates stored in `prefsBox`.

Why people pay: Streaks are emotionally powerful. The fear of breaking one is real. Shielding one feels premium and fair.

---

### 4. Photo Proof / Accountability Log
*"A picture is worth more than a checkmark."*

Users can attach a photo to a habit completion — a gym selfie, their book open to the page, their filled water bottle. Photos are stored in the app's local photo library (no cloud upload in v1; cloud backup in v2).

Gallery view: a month-view grid of your proofs — a visual diary of your consistency.

Implementation: `image_picker`, stored as file paths in `HabitLogModel`.

Why people pay: The gallery becomes a physical record of change. People scroll it when they feel like quitting.

---

### 5. Unlimited Habits & Goals
*No cap.*

Free tier: up to 5 habits, 2 goals.  
Premium: unlimited.

This is the most straightforward paywall. Do not be aggressive about it — show it when the user tries to add their 6th habit with a friendly, non-shame message.

---

### 6. Widgets (Home screen + Lock screen)
*"Your habits are always one glance away."*

- **Small widget** (2×2): Today's ring + done/total count
- **Medium widget** (4×2): Ring + top 3 habit status as rows
- **Lock screen widget** (iOS 16+): Progress ring with percentage

Implementation:
- iOS: WidgetKit (Flutter via method channel or `home_widget` package)
- Android: App Widget + `home_widget` package
- Data bridge: widget reads from shared group container (iOS) or SharedPreferences bridge (Android)

Why people pay: Visibility drives behavior. Having the ring on the lock screen is powerful.

---

### 7. Detailed History — Unlimited Calendar View
*"Your complete record."*

Free tier: last 30 days in the activity graph.  
Premium: full history back to day 1. Tap any day in the activity graph to see a complete log: habits done, mood, photo proofs, notes.

Implementation: Hive stores everything; the 30-day gate is just a query limit in the UI layer.

---

### 8. Custom Reminders — Per-Habit, Time + Message
*"Not just 'reminder at 8 AM' — your words, your time."*

Free: one daily reminder, global.  
Premium: per-habit reminders with a custom message ("Don't forget your run — you said you would") at exact times.

Implementation: `flutter_local_notifications` with exact scheduling per habit. Premium gate on the per-habit reminder UI in `AddHabitScreen`.

---

### 9. Export — PDF Report & CSV
*"Own your data, beautifully."*

- **PDF Report**: A beautifully designed monthly report — cover page with the month's score, habit-by-habit breakdown, mood graph, activity calendar. Uses the design system.
- **CSV**: Raw log export — habit, date, completed, mood, notes.

Implementation: `pdf` package (Flutter PDF) for report, `csv` package for raw export.

Why people pay: Serious people want to print this. Or share it with a therapist, coach, or accountability partner.

---

### 10. Themes — Dark Mode + Parchment Night
*"Warm paper, even at 2 AM."*

Free: Light (warm paper) mode only.  
Premium: Dark mode (parchment night) + 2 additional paper color themes:
- **Midnight** — deep charcoal, cream ink
- **Forest** — dark green tones for sage-loving users
- **Stone** — cool grey, like a modern notebook

Implementation: `ThemeData` switching with custom `ColorScheme` per theme, persisted in `prefsBox`.

---

### 11. Forma Journal — Free-form Daily Note
*"Beyond habits — a space for reflection."*

A daily free-form text note, separate from the mood input. Think of it as a one-paragraph private diary entry. Linked to the day's log, searchable in Premium.

Free: Write journal entries.  
Premium: Search across all entries, AI-generated monthly journal summary.

---

## Premium Pricing

| Plan | Price | Notes |
|---|---|---|
| Monthly | ₹199/month | For testers and uncommitted users |
| Annual | ₹999/year | **Push this** — 58% savings, better LTV |
| Lifetime | ₹2,499 (launch promo) | One-time, creates power users and word-of-mouth |

The lifetime plan should have a limited-time label on launch ("Founding member pricing") and be removed after 60 days. This creates urgency without being manipulative.

---

## Paywall Trigger Points

| Action | Trigger message |
|---|---|
| Adding 6th habit | "Forma is growing with you — unlock unlimited habits with Pro." |
| Adding 3rd goal | "Ambitious. Unlimited goals await in Forma Pro." |
| Tapping "Mood × Habits" insight | Shows blurred preview, "Available in Pro." |
| Scrolling past 30-day graph limit | "Your full story, back to day one. Available in Pro." |
| Tapping "Export" | "Take your data anywhere — PDF and CSV export in Pro." |

**Tone rule:** Never shame. Always frame as "you're the kind of person who wants this." The paywall should feel like an invitation, not a wall.