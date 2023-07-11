self.addEventListener('push', event => {
  const { image, tag, url, title, text } = event.data.json();
  const options = {
    data: url,
    body: text,
    icon: "/mlo.png",
    vibrate: [200, 100, 200],
    tag: tag,
    // REQUIRES HTTPS image: "/stadium.jpg",
    badge: "/favicon.ico",
    actions: [{ action: "Detail", title: "URL", icon: "/favicon.ico" }]
  };
  event.waitUntil(self.registration.showNotification(title, options));
})

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    clients.openWindow(event.notification.data.url)
  );
});