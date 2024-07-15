var CACHE_VERSION = 'v1';
var CACHE_NAME = CACHE_VERSION + ':sw-cache-';

function onInstall(event) {
  console.log('[Serviceworker]', "Installing!", event);
  event.waitUntil(self.skipWaiting());
}

function onActivate(event) {
  console.log('[Serviceworker]', "Activating!", event);
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.filter(function(cacheName) {
          // Return true if you want to remove this cache,
          // but remember that caches are shared across
          // the whole origin
          return cacheName.indexOf(CACHE_VERSION) !== 0;
        }).map(function(cacheName) {
          return caches.delete(cacheName);
        })
      );
    })
  );
}

// Borrowed from https://github.com/TalAter/UpUp
function onFetch(event) {
  event.respondWith(
    // try to return untouched request from network first
    fetch(event.request).catch(function() {
      // if it fails, try to return request from the cache
      return caches.match(event.request).then(function(response) {
        if (response) {
          return response;
        }
        // if not found in cache, return default offline content for navigate requests
        if (event.request.mode === 'navigate' ||
          (event.request.method === 'GET' && event.request.headers.get('accept').includes('text/html'))) {
          console.log('[Serviceworker]', "Fetching offline content", event);
          return caches.match('/offline.html');
        }
      })
    })
  );
}

function onPush(event) {
  const { image, tag, url, title, text } = event.data.json();
  const options = {
    data: url,
    body: text,
    icon: "/mlo.png",
    vibrate: [200, 100, 200],
    tag: tag,
    image: "/stadium.jpg",
    badge: "/favicon.ico"
    //actions: [{ action: "Detail", title: "URL", icon: "/favicon.ico" }]
  };
  event.waitUntil(self.registration.showNotification(title, options));
}

function onNotificationClick(event) {
  event.notification.close();
  var link_to = event.notification.data.link_to;

  // event.waitUntil(clients.matchAll({
  //   type: "window"
  // }).then(function(clientList) {
  //   for (var i = 0; i < clientList.length; i++) {
  //     var client = clientList[i];
  //     var regexp = new RegExp(link_to + '$');
  //     var match = client.url.match(regexp);

  //     if (match != null && 'focus' in client)
  //       return client.focus();
  //   }
  //   if (clients.openWindow) {
  //     return clients.openWindow(link_to);
  //   }
  // }));
}


self.addEventListener('install', onInstall);
self.addEventListener('activate', onActivate);
self.addEventListener('fetch', onFetch);
self.addEventListener('push', onPush);
self.addEventListener('notificationclick', onNotificationClick);