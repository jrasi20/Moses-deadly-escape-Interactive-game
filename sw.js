/* Bible Explorer Kids — shared service worker for the whole bundle
   (index + scene1 + scene2 + scene3). Gives returning/!first-load kids
   instant loads and instant scene-to-scene jumps by runtime-caching
   same-origin assets, plus offline resilience.

   IMPORTANT: bump CACHE_VERSION whenever you change game assets/code so
   returning kids get the fresh files instead of a stale cache.

   Note: an earlier inline blob:-URL service worker in scene1 never actually
   registered (modern browsers reject blob: SW scripts), so this external
   file is the first working SW. It only runs over http(s)/localhost — on a
   file:// build it simply never registers (harmless). */
const CACHE_VERSION = 'bek-bundle-v42'; // v42: onboarding trimmed to the canonical 3 modal steps (rest via JIT tips); mini-game Show-Me idle hints — if a kid is stuck ~5s in the match3 / sort / merge checkpoint games, the next move auto-demonstrates (glow a winning swap / glow a picture+basket / pulse the best arrow) plus a one-time plain-language toast, so kids who "don't know how to play" get guided. // v41: resume gating + visible checkpoints + crisp tutorials v41: Scene-3 UX fixes — (1) resume modal no longer shows on 0-progress: save only persists after ≥1 checkpoint cleared, and a 0-of-N or dead save is never resumable (matches the scene-specific resume contract); (2) checkpoints now render a glowing scripture-SCROLL marker on the tile (was only a floating "!", so kids couldn't see the checkpoint); (3) onboarding tutorial cut from 6 dense paragraphs to 5 crisp one-liners. // v40: wired dropped scene-3 art v40: actually WIRE the dropped scene-3 art — crystal-stone sprite on built stepping stones, painted grey wolf sprites in the rescue mini-game (dir-aware + mirror fallback), market-stall + flock-signpost decor in the west marketplace, all via a graceful auto-loader that falls back to procedural art on 404 (river-water tile already auto-loaded). // v39: rescue economy rebalanced for a real earn-and-spend loop — bounties trimmed so a kill ~breaks even against weapon cost (tight per-round PURSE), combo bonus reduced, per-difficulty purse retuned; the permanent BANK now grows by end-of-round PERFORMANCE (driven-off x4 + daughters-saved x15 + stars x20) instead of raw bounties, so riches still climb generously each play (invalidate stale v38) // v38: merge of scene3-epic + polished rescue mini-game, PLUS new scene-3 art (crystal/flock/market/river/wolves) wired, cinematic camera punch-in on wave/boss entry + boss looms larger, Start-Rescue paints the field before the countdown audio (double-rAF) with a loading-bar safety net so a restart never opens on blank sprites, and the Well-tried modal now uses cover-page music + well-tried sting (invalidate stale v37)

self.addEventListener('install', () => {
  // Activate immediately so the first navigation after install is controlled.
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil((async () => {
    // Drop any older-version caches so a CACHE_VERSION bump fully refreshes.
    const keys = await caches.keys();
    await Promise.all(keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  let url;
  try { url = new URL(req.url); } catch (_) { return; }
  if (url.origin !== self.location.origin) return; // never touch cross-origin

  const isHTML = req.mode === 'navigate' || req.destination === 'document';

  if (isHTML) {
    // Network-FIRST for HTML so code/content updates always come through;
    // fall back to cache only when offline. `cache: 'reload'` makes the
    // network fetch BYPASS the browser HTTP cache — without it, GitHub Pages'
    // `Cache-Control: max-age=600` on the HTML means a plain fetch() can hand
    // back a stale page for up to ~10 min after a deploy (the cache bug kids
    // kept hitting). With reload we always revalidate against the server.
    e.respondWith(
      fetch(req, { cache: 'reload' })
        .then((res) => {
          if (res && res.status === 200) {
            const copy = res.clone();
            caches.open(CACHE_VERSION).then((c) => c.put(req, copy)).catch(() => {});
          }
          return res;
        })
        .catch(() => caches.match(req))
    );
    return;
  }

  // Assets (images / audio / css / js): cache-FIRST for instant repeat loads
  // and instant scene jumps; populate the cache on first fetch.
  e.respondWith(
    caches.match(req).then((hit) =>
      hit ||
      fetch(req)
        .then((res) => {
          if (res && res.status === 200 && (res.type === 'basic' || res.type === 'default')) {
            const copy = res.clone();
            caches.open(CACHE_VERSION).then((c) => c.put(req, copy)).catch(() => {});
          }
          return res;
        })
        .catch(() => hit)
    )
  );
});
