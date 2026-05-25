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
const CACHE_VERSION = 'bek-bundle-v29'; // v29: capped round PURSE economy (separate from the permanent BANK that unlocks weapons & grows by treasure collected); lane THREAT WARNING (edge glow + warning icon + soft alert before a grab); COMBO streak bonus for quick downs; GENTLE first wave + early lane-cap difficulty tuning (invalidate stale v28) // v28: tutorial steps capitalized; ONE live treasure pool (round opens with real banked treasure, no trickle, spend deducts / down adds, net banked at end and never shrinks); win modal shows bank old→new and Replay is always offered; staff is now a thrown short-range spinning projectile that lands on the shepherd; HP meters + boss banner clamped so they never clip on the top lane; full 5-weapon squad required before Start; field background always paints a green base so the playfield never renders bare (invalidate stale v27)

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
