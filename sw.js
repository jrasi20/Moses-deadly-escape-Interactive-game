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
const CACHE_VERSION = 'bek-bundle-v4';

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
    // fall back to cache only when offline.
    e.respondWith(
      fetch(req)
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
