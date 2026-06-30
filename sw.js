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
const CACHE_VERSION = 'bek-bundle-v114'; // bump to invalidate caches on each release. History: see CHANGELOG.md

// Scene-3 opening shell: precache so the first screen is instant + offline-safe
// on returning devices. Kept small + resilient (allSettled ignores any miss) so a
// single bad/renamed URL can never abort the install. Everything else stays
// cache-first on demand. Filenames must match assets/images exactly (%20 = space).
const PRECACHE = [
  'scene3_midian.html',
  'assets/images/midian%20grass%20tile.png',
  'assets/images/scene3%20background.png',
  'assets/images/scene3_background_portrait.png',
  'assets/images/moses%20front%20facing.png',
  'assets/images/moses%20back%20facing.png',
  'assets/images/moses%20left%20facing.png',
  'assets/images/moses%20right%20facing.png',
  'assets/images/wolf%20right%20facing.png',
  'assets/images/wolf%20left%20facing.png',
  'assets/images/sheep.png',
  'assets/images/intro%20scene%203.png',
  'assets/images/jethro%20tent.png',
];

// Jane 2026-06-24: let the page ASK which version is actually active, so a tiny badge
// on the cover can confirm the phone isn't stuck on a stale cached build.
self.addEventListener('message', (e) => {
  try {
    if (e.data === 'getVersion' && e.source) e.source.postMessage({ type: 'swVersion', version: CACHE_VERSION });
  } catch (_) {}
});

self.addEventListener('install', (e) => {
  // Warm the opening-shell cache, then activate immediately so the first
  // navigation after install is controlled. Precache failures are non-fatal.
  e.waitUntil((async () => {
    try {
      const c = await caches.open(CACHE_VERSION);
      await Promise.allSettled(PRECACHE.map((u) => c.add(new Request(u, { cache: 'reload' }))));
    } catch (_) { /* ignore — runtime cache-first still populates on demand */ }
    await self.skipWaiting();
  })());
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
