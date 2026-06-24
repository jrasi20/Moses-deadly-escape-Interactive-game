# Bundle 2 — *In Moses's Sandals: Staffs of Light*

**Status:** Design locked 2026-06-25 · Prototype Chapter 1 Level 1 building now
**Scripture:** Exodus 3:1–7:13 (calling → first signs → first defiance → renewal → staff-swallows-magicians)
**Working title:** *In Moses's Sandals: Staffs of Light*
**Brand thesis:** "Step into the shoes of your favorite Bible character"
**Target:** Etsy buyers + Google Play Store (via TWA wrap of existing PWA)

---

## 1. Vision

> The kid doesn't *learn that* Moses defeated Pharaoh's magicians — the kid **becomes Moses** doing it.

Bundle 1 succeeded quietly because of identification, not information. Bundle 2 names that and makes it the brand: every game in our future line is **"step into the shoes of [character]."** Each character's defining object/place dictates the genre.

For Moses: the **staff**. The genre that fits the staff is the chase, because Exodus 7:12 literally says Aaron's staff *"swallowed up"* the magicians' staffs. Pac-Man + Snake hybrid maps to the scripture more cleanly than any Christian game on the market today.

### The five non-negotiables

1. **Mechanic mirrors scripture.** The "swallowing" of Ex 7:12 IS the gameplay.
2. **Kid plays as Moses in first-person framing.** HUD says "YOUR staff," verses use `bek.kidName`.
3. **Sandal-removal ritual opens and closes every session.** Brand signature.
4. **Verses appear naturally between gameplay** — never as quiz interruptions.
5. **Replayable in 60-90 sec rounds with a 3-star scoring system + daily challenge.**

---

## 2. Why this scope

After three rounds of design iteration we landed here:

- ❌ NOT 3 separate scenes — too much engine work for diminishing returns
- ❌ NOT a farming/brick-gathering game — makes the kid the oppressed; emotionally upside-down
- ✅ ONE game, ONE mechanic, deep replayability through content variety

That's how *Crossy Road, Subway Surfers, Among Us, Angry Birds* all work — one mechanic, lots of content.

---

## 3. Game architecture: 35 levels in 4+1 chapters

| Chapter | Levels | Theme | New thing |
|---|---|---|---|
| **0. The Calling** (tutorial) | 5 | Mt Horeb. Gather scattered sheep into a trailing line. Reach the burning bush. Sandal-removal ritual. God calls the kid's name. | Controls + trailing mechanic + sandal ritual |
| **1. The Staff of Power** | 10 | Pharaoh's outer court. Pure chase. 1 → 3 magician staffs per level. Split-screen Hebrew strip. | Chase + staff-trail-glow |
| **2. The Healing Hand** | 10 | Inner court. Tap leprous-hand power to **freeze** one magician staff for 5 sec. (Ex 4:6) | Freeze power-up |
| **3. Waters of Truth** | 10 | Throne room. Water-to-blood power **floods part of the arena red and impassable** — reshapes the maze in real-time. (Ex 4:9) | Flood power-up + maze deformation |
| **4. Before Pharaoh** (boss) | 5 | All powers unlocked. 5 magician staffs at once. Pharaoh watches. Boss = giant golden cobra (silhouette only, no snake imagery on field). | All powers combined |

Total levels: **35**. Average level length: **60–90 sec**. First playthrough end-to-end: **40–60 min**.

---

## 4. Core mechanic spec

### 4.1 The arena (maze)

- **Pac-Man-style maze.** Yes, must be a maze — corridor structure gives the chase tactical depth (corner vs. get cornered).
- **Grid:** 10 cols × 14 rows (portrait) or 14 × 10 (landscape).
- **Tile types:** wall (Pharaoh-court pillar), corridor (golden palace tile), pickup (small light orb — collects = +score).
- **Aesthetic:** Pharaoh's throne room. Walls are stylized pillars; corridors are golden tile from Bundle 1's `palace floor.png` family.

### 4.2 Moses's staff (player)

- One tile head + a fading glow trail behind. The trail is **visual only — no self-collision in easy/medium**. Hard mode adds self-collision (classic Snake).
- Movement: tile-by-tile, queued turns (Pac-Man feel).
- Glows brighter as you absorb more enemy staffs (`globalAlpha` + `shadowBlur` increase per kill).

### 4.3 Magician staffs (enemies)

| Color | Behavior | Catch strategy |
|---|---|---|
| 🔴 Red | **Runs from you.** Picks direction that maximizes distance. | Corner against a wall |
| 🔵 Blue | **Wanders randomly.** Random direction each intersection. | Catch when paths cross |
| 🟣 Purple | **Chases you.** BFS toward player. | Outmaneuver, lure into corner |

### 4.4 No snakes on screen

**Visual decision (locked):** No serpent imagery on the arena. The staffs are glowing rods; their movement is "scooting" not "slithering." When Moses's staff absorbs an enemy, a half-second flash of golden light dissolves the enemy — no snake silhouette. Exodus 7:12 is preserved in the *verse panels* between levels, not in the gameplay visuals. Parents and Etsy reviewers won't flinch.

### 4.5 Win/lose

- **Win:** Absorb all magician staffs within the timer (Easy 90 sec / Medium 60 sec / Hard 45 sec).
- **Partial win:** Absorb some — get 1 or 2 stars.
- **Lose:** Timer hits 0 with any magician staff alive. "Try again?" modal.

### 4.6 Split-screen Hebrew consequence

Bottom 25% of canvas (or sidebar in landscape):

- 5 small Hebrew slave sprites (Bundle 1 has `color hebrew slaves.png`, `color hebrew slaves 2.png`)
- Each carries a brick stack; brick count rises every 2 sec the timer runs
- Each enemy staff absorbed → 5 bricks lifted from each slave (visual: they straighten + a tiny cheer SFX)
- Win → slaves drop bricks entirely + smile
- Lose → slaves collapse under bricks (NOT graphic — just sit down + sad music). "Try again to free them"

This is the emotional engine of the bundle. The kid isn't chasing a high score — they're carrying real weight off real people.

### 4.7 Powers (unlock chapter-by-chapter)

| Power | Unlock | Effect | Bible anchor |
|---|---|---|---|
| **Staff trail glow** | Always on | Visual; brighter = more score | Ex 4:2 ("What is that in your hand?") |
| **Leprous hand freeze** | Chapter 2 | Tap → freeze one magician for 5 sec | Ex 4:6 ("his hand was leprous, like snow") |
| **Nile-water flood** | Chapter 3 | Tap → 3 tiles in chosen row turn red & impassable for 8 sec | Ex 4:9 ("the water will become blood") |
| **Burning bush flame** | Chapter 4 boss | Pickup drop — 3 sec invincibility | Ex 3:2 |

Powers have **cooldowns** so kids can't spam — strategic positioning matters.

---

## 5. Verse-act panels

Cinematic comic-style panels (reuse Bundle 1's `prelude-`, `opening-`, `closing-`, `trans-` PNG format).

**When they fire:**
- Bundle opening: 3 panels (Ex 2:23-3:1 — "the Israelites groaned… Moses was tending the flock")
- Chapter transitions (4 of them): 2-3 panels each covering the next chapter's verses
- Mid-chapter: 1 panel after level 3 of each chapter, with a key verse
- Boss intro: 2 panels (Ex 7:8-10)
- Win ending: 3 panels (Ex 7:12-13) + foreshadow Bundle 3 (the Plagues)

**Total panels:** ~30 across the bundle. Most reuse Bundle 1 art (calling+desert+wilderness imagery already exists). New panels needed: ~10–12 for the throne-room and magicians scenes.

**Skippable on replay.** First-time players see all; returning players tap-to-skip.
**Voice option:** TTS narration available for kids who can't read well yet (reuses Bundle 1's voice-onboarding infra).

---

## 6. Replayability hooks

1. **3-star scoring per level.** Stars from: time remaining, enemies absorbed, no-damage bonus.
2. **Daily challenge.** One random level per day with a modifier ("no power-ups," "darkness — half the arena hidden," "double-speed enemies"). Resets every 24h via localStorage timestamp. Daily challenge is *the* hook that makes parents allow 5–10 min/day.
3. **Endless mode.** Unlocked after boss. One arena, magicians keep summoning, see how long you survive. Local leaderboard.
4. **Truth Card collection.** Reuses Bundle 1's pool — kids collect 50+ cards across both bundles.
5. **Hidden levels.** Unlock by collecting all Truth Cards in a chapter.
6. **Difficulty re-runs.** Easy unlocked first; Medium/Hard re-unlock the full game.

---

## 7. Bundle 1 reuse pointers

What we get for free (zero engine work):

| Bundle 1 system | Where to find it | How Bundle 2 uses it |
|---|---|---|
| Cover page + access gate (SHA-256 hashed codes) | `scene2_desert.html:5127–5190` | Same UX, new codes |
| Cinematic / verse-panel renderer | `scene2_desert.html` `openCinematic()`, `CIN_PANELS` array (~L5192) | Reuse for chapter intros + verse acts |
| HUD with hearts/score/timer | `scene2_desert.html:2080–2090` area + `updateHud()` | Drop in same chips |
| D-pad + keyboard controls | `scene2_desert.html:4725–4751` (`handleKeyPress`, `dirBtn`) | Same input handler |
| Touch + swipe handlers | `scene2_desert.html:5054–5063` | Same |
| Audio unlock + throttled play | `scene2_desert.html:2583–2649` (`unlockAudio`, `play()`) | Drop in same |
| Audio asset list (chime/click/error/success/win etc.) | `scene2_desert.html:2333–2380` (40 tracks) | Reuse most directly |
| Pre-render pipeline for large images | `scene2_desert.html:2810` (`_preRender`) | Reuse — speeds up first paint |
| Preload progress overlay | `scene2_desert.html:5102–5124` | Same pattern |
| Win/lose modal layouts | `scene2_desert.html:2240–2300` | Restyle but keep structure |
| Save-progress to localStorage | `scene2_desert.html:5293–5345` | `bek.bundle2.progress` namespace |
| Difficulty config | `scene2_desert.html:3234` (`DIFFICULTY_CONFIG`) | Same shape, different numbers |
| Tutorial overlay system | `scene2_desert.html:5575–5601` (`CONTROLS_TUT_STEPS`, `_composeTutorialSteps`) | Reuse for Chapter 0 |
| Responsive media queries | `scene2_desert.html:278–295, 514, 652, 1497–1502, 1875+` | Copy bodily |
| Service worker | `sw.js` | Add Bundle 2 file to precache list, bump cache version |
| Asset manifest | `assets-manifest.json` | Append Bundle 2 assets |
| Certificate generator | `certificate.html` | Reuse with `bek.bundle2.rank` |
| PWA install button | `scene1_palace.html:~23395` | Reuse as-is |
| Sequential gating | `scene2_desert.html:32-42` (head script) | `bek.bundle2.progress` |
| Truth Card cross-scene pool | `scene2_desert.html` truthchest plumbing | Extend pool |
| Sandal-ritual long-press | NEW — adds to Bundle 1 too eventually | Bundle 2 ships it first |

### Reusable image assets (no new art needed)

- All Moses sprites (8 directions) + staff variants
- All sheep + lamb sprites (for Chapter 0)
- Mt Horeb terrain (terebinth, midian rock, sand tiles)
- All Pharaoh sprites (front/back/L/R + chariot — for boss intro)
- All Egyptian guard sprites (the "magicians" can be palette-shifted guards holding glowing rods)
- Palace pillars, palace floor variants, palace throne (all 4 chapter arenas)
- Hebrew slave sprites (`color hebrew slaves`, `color hebrew slaves 2`) — for the split-screen strip
- `bricks.png`, `shepherd staff.png`, `shepherds staff.png`
- All `prelude-`, `opening-`, `trans-`, `closing-`, `epilogue-` panel images
- Burning bush — **WAIT, needs creation**. None in Bundle 1.

### New art needed (~10–15 PNGs only)

- Burning bush (4 anim frames — could be one PNG with CSS animation)
- Magician sprite (or palette-shift egyptian guard) × 3-4 colors
- Glowing staff tokens — red / blue / purple / golden (4 simple PNGs)
- Pharaoh enthroned-and-watching pose (variation)
- 5–8 verse-panel illustrations specific to throne-room scenes
- (Optional) Boss golden cobra silhouette

**Estimated art creation time:** 1–2 weeks via AI image gen + cleanup.

### New audio needed (~6 clips)

- Staff-absorb shimmer SFX (~0.3 sec)
- Maze BGM (~1 min loop, Egyptian feel — already have `egyptian music.mp3`)
- "I AM" voiceover for bush scene (TTS via ElevenLabs sample voices)
- "Let my people go" voiceover
- Magician chant (~2 sec loop)
- Brick-relief cheer (already have `friendly alert.mp3` — could reuse)

---

## 8. Responsive design requirements

**Non-negotiable:** must work on iOS Safari, Android Chrome, Windows Edge/Chrome, macOS Safari/Chrome, in BOTH portrait and landscape.

### Layout per device class

| Device | Orientation | Maze size | HUD | Controls | Hebrew strip |
|---|---|---|---|---|---|
| Phone | Portrait | 10×14 (vertical) | Top bar | D-pad bottom | Below D-pad OR collapsed |
| Phone | Landscape | 14×10 (horizontal) | Top bar | D-pad bottom-left, action right | Right sidebar |
| Tablet | Portrait | 12×16 | Top bar | D-pad bottom OR swipe-only | Below maze |
| Tablet | Landscape | 16×10 | Top bar | D-pad bottom-left | Right sidebar |
| Desktop | Any | 14×10 fixed | Top bar | Arrow keys / WASD primary | Right sidebar |

### Required CSS techniques (copied from Bundle 1)

- `height: 100dvh; height: 100svh;` for viewport (handles iOS URL-bar collapse)
- `env(safe-area-inset-*)` for notch/Dynamic Island
- `@media (orientation: portrait)` and `@media (orientation: landscape)` branches
- `clamp(min, ideal, max)` for fluid sizing
- `viewport-fit=cover` in meta viewport

### Required JS for cross-platform

- `unlockAudio()` on first user gesture (iOS requires)
- DPR-aware canvas resize (Bundle 1 caps at DPR 4)
- Both `touchstart` AND `pointerdown` AND `keydown` handlers
- `requestFullscreen` best-effort on first gesture (mobile Chrome)
- Service worker registration for offline play

### Required testing matrix before ship

- [ ] iPhone SE (smallest current iOS — 320×568 portrait)
- [ ] iPhone 15 (notch + Dynamic Island)
- [ ] Android phone 360×640 portrait + landscape
- [ ] iPad portrait + landscape
- [ ] Desktop 1920×1080 + 1366×768
- [ ] PWA-installed mode on iOS + Android

---

## 9. Cross-bundle integration

Bundle 1 stays the way it is. Bundle 2 is a separate URL/file (`bundle2_staff_chase.html`) that:

- **Reads** `bek.kidName` from Bundle 1 (kid's name carries over)
- **Reads** `bek.bundle1.progress` (Bundle 2 access can be gated on Bundle 1 completion as upsell)
- **Writes** `bek.bundle2.*` keys (own namespace)
- **Shares** the same access codes (player only enters once)
- **Shares** the certificate page (`certificate.html` reads from a `bek.heroJourney.bestRank` aggregate key)

This is the foundation of "Moses Saga Bundle 1+2" combo pricing on Etsy.

---

## 10. Scope estimate

| Item | Time | Status |
|---|---|---|
| Design + storyboard docs | 1 day | ⏳ in progress |
| Chapter 1 Level 1 playable prototype | 1 day | ⏳ in progress |
| Chapter 0 (tutorial) full 5 levels | 1 week | not started |
| Chapter 1 full 10 levels | 1 week | not started |
| Chapter 2 + leprous freeze power | 1 week | not started |
| Chapter 3 + flood power | 1 week | not started |
| Chapter 4 boss + ending | 1 week | not started |
| Verse panel art + audio | 1–2 weeks (parallelizable) | not started |
| Cross-device + orientation testing | 1 week | not started |
| Etsy listing + Play Store TWA | 1 week | not started |
| **Total** | **7–9 weeks part-time** | |

---

## 11. Definition of "Play Store sensation level"

For Bundle 2 to clear the bar:

- **First win < 60 sec** from app open
- **Each round 60-90 sec** (mobile attention span)
- **3-star scoring** that kids can chase
- **Daily challenge** that gives a reason to open the app tomorrow
- **Verses appear glanceably** (3-4 sec panels), never as quiz interruptions
- **No ads, no IAP** (parent gold-standard)
- **Offline playable** (PWA + SW)
- **Installable to home screen** (PWA install button)
- **Sub-2-MB initial load** (excluding cached assets)
- **Lighthouse PWA score > 90**
- **TWA-wrappable** for Google Play submission with zero code changes

---

## 12. Open questions to decide as we build

1. **Hard mode self-collision** — should the trail glow be collidable in Hard difficulty (classic Snake) or just visual (classic Pac-Man)? *Tentative: visual-only in Easy/Medium, collidable in Hard.*
2. **Magician sprites** — palette-shift existing Egyptian guards, or commission new art? *Tentative: palette-shift to ship faster.*
3. **Burning bush** — 4-frame anim or CSS-only flicker? *Tentative: 1 PNG + CSS keyframes.*
4. **Sandal ritual** — long-press 1 sec or 2 sec? *Tentative: 1.5 sec with progress ring.*
5. **TTS voice for kidName** — pre-baked common names + fallback text? Or full TTS on the fly? *Tentative: pre-baked top 50 kid names + text fallback for the rest.*

---

## 13. Next actions

1. ✅ Lock design doc (this file)
2. ⏳ Write `BUNDLE2_STORYBOARD.md` (level-by-level beats)
3. ⏳ Build `bundle2_staff_chase.html` prototype (Chapter 1 Level 1 playable)
4. ⏳ Push to `claude/bundle2-staff-chase` branch
5. **Playtest with one 7-year-old.** If they ask to play again → green light for the full build.

— *Locked 2026-06-25. Iterate this doc as design decisions land.*
