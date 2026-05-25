# Scene 3 (Midian) — Image Asset Prompts & Art Guide

Status date: 2026-05-25

## TL;DR — what already works
- **The green pasture tile WORKS.** `assets/images/midian grass tile.png` (643 KB) is
  loaded and rendered by `drawTile()` for every Scene-3 floor tile, with a small
  per-tile hue shift + sparse wildflowers on top to break up the grid.
- **~400 Scene-3 images already exist on disk** and are wired in the manifest:
  sheep (4 directions), lambs, goat, well (mouth/bucket/midian well), Jethro +
  tent + 7 daughters (+ right-facing + kidnapped variants), rude shepherds (many
  poses), rescue mini-game sprites, water pots/jars, crown, stone pen wall, palms,
  reeds, jar piles, hearth, background, etc. **No referenced file is missing.**
- The only real GAP is the **river water tile** (see #1). Everything else below is
  optional polish to push the scene to "Play-Store grade."

> Format conventions for everything below: **PNG**, **square**, **1024×1024**,
> flat 2D **storybook-cartoon** style matching the existing art (soft cel shading,
> warm golden-hour light, rounded forms, gentle outlines — same look as
> `scene3_background.png` and the sheep sprites). Filenames must match EXACTLY
> (spaces become `%20` in code — keep real spaces in the filename on disk).

---

## 1. River water tile — **CRITICAL (only true gap)**
File: `assets/images/river water.png`  → auto-loads (no manifest edit needed).

The river is now 3 tiles wide. This image is drawn per-tile, scrolled vertically
for flow, with a 2nd parallax layer + animated caustics/sparkles/foam on top.

**Prompt:**
> Seamless top-down water texture tile for a children's Bible game, clear shallow
> desert stream. Gentle turquoise-to-deep-blue gradient, soft ripples and subtle
> light caustics, hand-painted storybook cartoon style, soft cel shading, no foam
> at edges, no shoreline, no objects — pure water surface. **Must tile seamlessly
> on all four edges (top↔bottom AND left↔right)**, edges colour-matched, no
> vignette, no border, even lighting. 1024×1024 PNG.

Tips: generate it tileable (most tools have a "seamless/tiling" toggle). Avoid any
single bright highlight or it will visibly repeat. Keep it fairly even/low-contrast
— the engine adds the shimmer, sparkle and depth on top.

---

## 2. Seamless grass tile — **HIGH (biggest beauty win)**
File: `assets/images/midian grass tile.png` (REPLACE existing)

The current grass tile is lovely but has **darkened vignette edges + a framed
composition**, so when tiled across the map you can faintly see a grid of repeating
darker borders. Regenerating it as a *truly seamless* tile removes the grid and
makes the whole pasture read as one continuous meadow.

**Prompt:**
> Seamless top-down grass meadow texture for a children's storybook game. Lush
> green spring grass with a few tiny white and yellow wildflowers and a couple of
> small pebbles scattered evenly. Hand-painted cartoon style, soft even lighting.
> **Perfectly tileable on all four edges**, NO vignette, NO dark border, NO frame,
> uniform brightness corner-to-corner so copies blend invisibly. 1024×1024 PNG.

(Keep the flowers/pebbles sparse and away from the edges so they don't line up into
rows when tiled.)

---

## 3. Crystal stepping-stone — OPTIONAL polish
Currently the 3 "crystal tiles" that build the crossing are represented by the 💎
emoji + procedural gold stepping stones. A real sprite would look richer.

File suggestion: `assets/images/crystal stone.png` (then wire `IMG.crystalStone`).

**Prompt:**
> Top-down glowing blue-white crystal embedded in a smooth river stepping-stone,
> for a children's Bible game. Faceted gem catching golden light, soft magical
> glow, rounded grey river stone base, storybook cartoon style. Transparent
> background (PNG-32), centred, slight drop shadow. 512×512.

## 4. "Lost flock" beacon / signpost — OPTIONAL
A small wooden "stray sheep" signpost to mark the west-bank flock before the
crossing is built (purely decorative; the engine already draws a glow ring).
> Small weathered wooden signpost with a painted sheep symbol, top-down/isometric,
> children's storybook cartoon style, transparent background, 512×512.

## 5. Daughters waiting at the pen — OPTIONAL cinematic touch
For the "flock is safe" cinematic you could place 1–2 of Jethro's daughters by the
pen waving. **Already have** `daughter N front facing.png` / `... right facing.png`
— no new art needed; this is just a placement idea.

---

## How to make everything look beautiful (art-direction checklist)
1. **One palette, one light source.** Everything should read as late-afternoon
   golden hour (matches `scene3_background.png`): warm highlights, cool soft
   shadows. Avoid pure black outlines — use dark warm brown.
2. **Seamless tiles are the #1 polish lever.** Floors (grass, water, sand) must
   tile invisibly. The current grass grid is the most visible rough edge.
3. **Consistent sprite scale + ground contact.** Characters/objects ~1 tile tall,
   feet at the tile's bottom edge, each with a soft elliptical contact shadow
   (the engine already adds these for sheep/Moses).
4. **Transparent backgrounds** on every object/character PNG (PNG-32), tight crop,
   centred horizontally.
5. **Depth via layering, not detail.** Keep individual tiles low-contrast; the
   engine layers lighting, dusk tint, caustics, glints and particles on top. Busy
   tiles fight the animation.
6. **Readability for kids.** Interactive things (crystals, crown, truth chest,
   well, exit) should pop with warm glow/sparkle; background scenery stays muted.

## Where the engine expects files
All paths live in the manifest inside `scene3_midian.html` (search
`SCENE 3 — THE WELL OF MIDIAN`). Drop a correctly-named PNG into
`assets/images/` and it lights up on next load — missing files fall back to
the previous/procedural art, so nothing breaks if a file isn't ready yet.
