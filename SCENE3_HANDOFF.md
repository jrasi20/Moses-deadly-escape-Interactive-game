# Scene 3 (Midian) — Work Hand-off

**Last updated:** 2026-05-25
**Working branch:** `claude/scene3-art-wiring` (branched off `main`; merge it, then branch new work off `main`)
**File:** `scene3_midian.html` (single-file scene). Bump `sw.js` `CACHE_VERSION` after every change.

> NOTE: Scene 3's internal engine id is `game.scene === 2` (preserved on purpose).
> So `game.scene !== 2` branches are effectively dead code in this file, and
> "Scene 2" in **code comments** refers to engine lineage — NOT a bug. Only fix
> "Scene 2" in **user-facing strings**.

---

## Done (verified via Playwright unless noted)

### Art wiring (assets the user dropped)
- `river water.png` (auto-loads), `crystal stone.png` (built stepping stones),
  `wolf left/right facing.png` (rescue minigame, dir-aware + mirror fallback),
  `market stall.png` + `optional market stall 2.png` + `flock signpost.png`
  (west marketplace decor). All via a 404-safe auto-loader (`_loadScene3Art`).

### UX / gameplay fixes
- **Resume modal** only appears with real progress: `_saveCheckpoint` refuses to
  write until ≥1 checkpoint cleared; `_loadCheckpoint` rejects 0-of-N or dead
  (hearts≤0) saves. (`openDanger` already clears the save on a catch.)
- **Visible checkpoints**: `drawChallengeGate` now draws a glowing scripture-scroll
  marker with "?" for Scene-3 `'zone'` gates (previously only a floating "!").
- **Onboarding** trimmed to 3 crisp modal steps (Move / Hide / Checkpoints); rest
  taught by JIT proximity tips + markers + EXIT beacon.
- **Proximity tip popups** (river / flock / shepherds) — `showTipPopup` +
  `_checkScene3Tips`, honor `bek.bundle1.tutMode` (popup ON, toast OFF).
- **Mini-game Show-Me hints**: match3 / sort / merge auto-demonstrate the next
  move after ~5s idle + a one-time plain-language toast.
- **Urgency**: rude-shepherd flock raid (Speed Burst / Foe Freeze now meaningful);
  Foe Freeze now also freezes the rude shepherds.
- **Powers**: all 6 verified firing; God's Grace (pharaohsMercy) added;
  Eagle Eye re-themed to the crossing + crown beacon.
- **Power dock**: first-tap pulse + "→ TAP" arrow (`bek.bundle1.puTapped`).

### Regression-checklist fixes (SCENE_2_3_REGRESSION_CHECKLIST.md)
- **C1** `render()` wrapped in `render()`+`_renderInner()` try/catch (no more
  black-canvas on a bad frame; error logged once).
- **E10** all power-up state resets in `restartScene` (cooldowns, active timers,
  truthSeeker/scribesWisdom armed, God's Grace).
- **D1** `toast()` dedupes identical msgs (6s) + short FIFO queue.
- **A1** master Sound mute: HUD 🔊/🔇 button, persists `bek.bundle1.soundOn`,
  mutes every track via `.muted`, `play()` bails when muted.
- **A17** `_killAllGameMusic()` helper, wired into all 3 "Main Menu" handlers.
- **Header** "SCENE 2 COMPLETE" → "SCENE 3 COMPLETE".

### Audit verified-present-and-correct (B/F/G/H/J)
- **B (NPC AI)**: shepherds don't chase while hidden (`moses_hidden` gate);
  contact = −1 heart + bounce + `invulnerableUntil` (no instant drain). Chariot/
  captain items (B5–B9) are N/A in Midian.
- **F (modals)**: win modal scrolls, all buttons reachable, conditional motivate
  text, "Replay Scene 3" label correct. Verified on 390×844.
- **G (responsive)**: portrait (HUD + canvas + stacked controls) and landscape
  (D-pad left / action pills right) both clean; HUD wraps. Verified on 390×844
  and 844×390.
- **H (scripture)**: midwives wording correct ("saved baby boys", Exodus 1:15-21,
  `scene3_midian.html` ~8624); lore modal "STORY UNLOCKED" present.
- **J (gameplay)**: exit-locked until all checkpoints solved (`onReachExit` path
  ~7195-7205); hard difficulty config present. `_softCatch` doesn't exist by name
  (Scene 3 handles catches inline) — not a bug.

---

## Remaining / open

### Needs an asset from the user (then ~10 min wiring)
1. **Seamless grass tile** — `assets/images/midian grass tile.png` has vignette
   edges that tile into a visible grid (violates "quiet floor"). Drop a truly
   seamless replacement (prompt in `ASSET_PROMPTS_scene3_midian.md` #4). Code
   already auto-loads it — no wiring needed.

### Code (nice-to-have, low risk)
2. **C5** GPU warm-up (`_warmGpuForAllSprites` via `requestIdleCallback` after
   images load) to reduce first-frame jitter on weak phones.
3. **D2** `toast(msg, {force:true})` to bypass dedupe for the hint button + the
   exit-locked warning.
4. **Cover-page Sound button** parity (the HUD one exists; cover-page has none).
   `bek.bundle1.soundOn` is shared, so it's cosmetic parity only.

### Deeper passes not yet done (need a careful read, not just grep)
5. **H question-bank review** — read the full Exodus 2:11-22 / Hebrews 11:24-26 /
   Acts 7:23-29 pool for awkward phrasing, letter-giveaway clues, or scope
   overlap with Scene 1 (canonical H3/H5 + buglog §12/§15/§16).
6. **B1 tuning** — consider bumping shepherd-contact `invulnerableUntil` from
   1200ms toward the canonical 3000ms breathing room if playtests show drain.
7. Full sweep of remaining F/G items vs `SCENE_2_3_REGRESSION_CHECKLIST.md`
   (most are present; this is a line-by-line confirmation pass).

---

## How to test
```
python3 -m http.server 8099    # from repo root
# open http://localhost:8099/scene3_midian.html?dev=1
```
Dev shortcuts: set localStorage `bek.dev=1`, `bek.moses3.tutDone=1`,
`bek.lastDifficulty=easy`, then in console `startScene1()`.
Syntax check after edits: extract `<script>` blocks and `node --check`.
Curly-quote guard: `python fix_js_quotes.py scene3_midian.html --check`.
