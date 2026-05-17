# Forma — Design System

> Warm paper · editorial serif · intentional restraint

---

## 1. Design Direction

Forma is **an analogue journal that happens to run on your phone.** The design evokes a physical habit journal — cream paper, ink, deliberate typography — but with the precision and delight that only digital can provide.

**Keywords:** warm, editorial, contemplative, structured, quietly satisfying  
**Anti-keywords:** techy, colorful, gamified, plastic, cluttered

The user should feel like they are *writing in a beautiful notebook*, not tracking data in an app.

---

## 2. Color Palette

### Base (Paper tones)

| Token | Hex | Use |
|---|---|---|
| `paper` | `#F5F0E8` | Primary background, card surfaces |
| `paper2` | `#EDE8DF` | Secondary surface, input fields |
| `paper3` | `#E4DDD2` | Tertiary surface, dividers, app bg |

### Ink (Text hierarchy)

| Token | Hex | Use |
|---|---|---|
| `ink` | `#1C1914` | Primary text, icons |
| `ink2` | `#5C5649` | Secondary text, body |
| `ink3` | `#9B9488` | Tertiary text, placeholders, labels |
| `ink4` | `#C4BEB4` | Disabled state, subtle borders |

### Accent (Sparingly)

| Token | Hex | Semantic use |
|---|---|---|
| `terra` | `#B85C38` | Primary brand, CTAs, destructive/alert |
| `sage` | `#5A7A5C` | Success, completed, positive |
| `gold` | `#A07830` | Secondary goals, reading goal color |
| `dust` | `#8C7B6A` | Neutral accent, progress bars |

### Activity Graph (4 shades + empty)

| Level | Token | Hex | Condition |
|---|---|---|---|
| 0 — none | `graphNone` | `#E4DDD2` | No habits or 0% |
| 1 — light | `graphLight` | `#B8D4B8` | > 0%, ≤ 25% done |
| 2 — medium | `graphMedium` | `#7AAD7A` | > 25%, ≤ 60% done |
| 3 — dark | `graphDark` | `#4A8C4A` | > 60%, < 100% done |
| 4 — full | `graphFull` | `#2D6E2D` | 100% done — all habits |

The full shade should feel earned. Light green is "I showed up." Full green is "I nailed it."

### Semantic

| Token | Value | Use |
|---|---|---|
| `line` | `rgba(28,25,20,0.08)` | Default dividers |
| `line2` | `rgba(28,25,20,0.14)` | Stronger borders |
| `terraDim` | `rgba(184,92,56,0.10)` | Terra background tint |
| `terraMid` | `rgba(184,92,56,0.25)` | Terra border tint |
| `sageDim` | `rgba(90,122,92,0.10)` | Sage background tint |
| `sageMid` | `rgba(90,122,92,0.20)` | Sage border tint |

---

## 3. Typography

### Typefaces

| Role | Family | Weights |
|---|---|---|
| Display / headings | **Fraunces** (variable, optical size) | 300, 400, 500; italic 300, 400 |
| Body / UI | **Instrument Sans** | 400, 500, 600 |

Both are Google Fonts. Bundle the WOFF2 files in `assets/fonts/` for offline availability.

### Type Scale

| Name | Font | Weight | Size | Use |
|---|---|---|---|---|
| `displayLarge` | Fraunces | 300 | 32 sp | Page titles |
| `displayMedium` | Fraunces | 300 italic | 26 sp | Highlight text |
| `headlineLarge` | Fraunces | 400 | 22 sp | Modal titles, section headers |
| `headlineMedium` | Fraunces | 400 | 18 sp | Card titles |
| `titleLarge` | Instrument Sans | 600 | 16 sp | Habit names |
| `titleMedium` | Instrument Sans | 500 | 14 sp | Settings rows, subtitles |
| `bodyLarge` | Instrument Sans | 400 | 15 sp | Body copy |
| `bodyMedium` | Instrument Sans | 400 | 13 sp | Secondary body |
| `labelLarge` | Instrument Sans | 600 | 12 sp | Buttons, CTAs |
| `labelSmall` | Instrument Sans | 600 | 10 sp | Eyebrows, badges, caps labels |

Line height: 1.5 for body, 1.15 for display. Letter-spacing: 0.05–0.10 em for `labelSmall` (caps) only.

### Italic usage

Use Fraunces italic for:
- The personalized name in greeting (`em` element)
- The word *story*, *journal*, *today* when used as a decorative word in a heading
- Pull-quotes and AI coach notes

---

## 4. Spacing System

Based on a 4 dp base unit:

| Token | Value | Use |
|---|---|---|
| `xs` | 4 dp | Icon gap, micro padding |
| `sm` | 8 dp | Between related elements |
| `md` | 16 dp | Default padding |
| `lg` | 24 dp | Section padding, card padding |
| `xl` | 32 dp | Large section gaps |
| `xxl` | 48 dp | Hero sections |

Screen horizontal padding: `22 dp` (consistent, not `md` — deliberate editorial margin).  
Content padding from top of safe area to first title: `18 dp`.

---

## 5. Elevation & Surfaces

Forma avoids Material-style drop shadows. Instead:

| Level | Treatment | Use |
|---|---|---|
| 0 | No border, no shadow | Inline rows (habit rows inside a card) |
| 1 | `1px solid line` border | Cards, goal blocks |
| 2 | `1px solid line2` + subtle shadow | Modal sheets, FAB |
| 3 | `paper` background + heavy shadow | Bottom sheet, overlays |

Shadow token: `0 1px 3px rgba(28,25,20,0.08), 0 4px 12px rgba(28,25,20,0.04)`  
No colored shadows. No multiple shadow layers beyond the above.

---

## 6. Border Radius

| Token | Value | Use |
|---|---|---|
| `rSm` | 8 dp | Buttons, inputs, small chips |
| `r` | 14 dp | Cards, goal blocks, modals |
| `rLg` | 20 dp | Bottom sheet corners |
| `rFull` | 999 dp | Pills, badges, checkboxes |

---

## 7. Iconography

No icon library. Forma uses:
- Unicode symbols for navigation (▣ ◈ ○) — character art, not SVG icons
- Emoji for habit icons — picked by the user, expressive and personal
- Simple geometric shapes (circles, lines) for UI elements like the progress ring

This is intentional — it reinforces the handcrafted, notebook feeling.

For the check animation: a Lottie animation (`assets/lottie/check_complete.json`) — a simple ink-stroke checkmark.

---

## 8. Component Specs

### Habit Row

```
Height: 54 dp (content, not fixed)
Left padding: 22 dp
Emoji icon: 32×32 dp, centered
Gap between icon and text: 12 dp
Name: titleLarge (16/600, Instrument Sans)
Meta (streak + heat): bodySmall (11/400)
Check button: 30×30 dp circle, 1.5 dp border
Completed check: sage fill + white ✓
Divider: 1 dp, line color
```

### Progress Ring

```
Outer diameter: 80 dp
Track stroke: 5 dp, line2 color
Fill stroke: 5 dp, sage, stroke-linecap: round
Animation: spring easing, 800 ms
Center text: Fraunces 400, 22 sp
"OF N" text: labelSmall, ink3
```

### Activity Graph Cell

```
Cell size: 10×10 dp
Corner radius: 2 dp
Gap between cells: 2 dp
Gap between week columns: 2 dp
Label row (Mon/Wed/Fri): labelSmall, ink3
Month label row: labelSmall, ink3
Long-press tooltip: paper2 background, 1 dp border, bodyMedium
```

### Modal Bottom Sheet

```
Overlay: rgba(28,25,20,0.5) + blur(4dp)
Sheet: paper background, 24 dp top radius
Handle: 32×3 dp pill, line2 color
Padding: 20 dp top, 22 dp sides, 40 dp bottom (safe area aware)
Title: headlineLarge (22/400, Fraunces)
Animation: spring slide-up, 300 ms
```

### Bottom Navigation

```
Height: 56 dp + safe area bottom
Background: rgba(245,240,232,0.92) + blur(16dp)
Top border: 1 dp, line2
FAB: 50×50 dp circle, ink bg, paper ✚, 8 dp above nav
Active icon/label: ink
Inactive icon/label: ink4
```

### Mood Selector

```
Dots: 36×36 dp circles, paper3 bg, line2 border
Selected: paper bg, ink2 border, scale(1.12), shadow level 2
Emoji: 18 sp
Row bg: paper2, 1 dp border, 14 dp radius
```

---

## 9. Motion Principles

| Principle | Implementation |
|---|---|
| **Purposeful** | Animation only communicates state change or guides attention |
| **Quick** | Most interactions ≤ 300 ms. Nothing > 600 ms except the ring |
| **Spring-like** | Use cubic-bezier(0.34,1.2,0.64,1) for "pop" moments (ring, check, confetti) |
| **Subtle** | Fade + micro-translate (8 dp) for list items entering/exiting |

Key moments with animation:
1. **Habit check** — Scale up (0.6→1.25→1.0), 300 ms spring. Confetti burst.
2. **Progress ring** — Stroke offset transition, 800 ms spring.
3. **Modal open** — Slide up from bottom, 300 ms spring.
4. **Screen transition** — Horizontal slide, 250 ms ease-out.
5. **Date strip scroll** — Momentum physics (platform default).

---

## 10. Dark Mode

Forma's dark mode inverts the paper metaphor to **aged parchment at night**:

| Light token | Dark equivalent |
|---|---|
| `paper` `#F5F0E8` | `#1A1714` |
| `paper2` `#EDE8DF` | `#221F1B` |
| `paper3` `#E4DDD2` | `#2A2620` |
| `ink` `#1C1914` | `#EDE8DF` |
| `ink2` `#5C5649` | `#A09890` |
| `ink3` `#9B9488` | `#6A6258` |

Accent colors (`terra`, `sage`, `gold`) remain identical — they read well on both backgrounds.

Dark mode is detected from `MediaQuery.of(context).platformBrightness`. No in-app toggle in v1.

---

## 11. Onboarding Screens (3 screens)

1. **Welcome** — Fraunces italic headline, "A journal for the version of you you're becoming." Lottie ink-pen writing animation.
2. **Add your first habit** — Minimal form, no pressure language. "Start small. One habit changes everything."
3. **Notifications** — Honest permission ask. Illustrated clock icon. No dark patterns.

Color: only paper + ink. Terra is used only for the CTA button. No illustrations with gradients.

---

## 12. Paywall Design

```
Structure:
  ─ Hero — large Fraunces italic headline
  ─ Feature list — 4–5 bullets, terra dots
  ─ Price — "₹199/mo · or ₹999/year"
  ─ CTA — terra filled button, full width
  ─ Restore purchases — ink3 text link
  ─ Privacy / Terms — ink4 text, 11 sp

Tone: "For people serious about change" — not "Upgrade Now!!"
No countdown timers. No fake social proof. No dark patterns.
```