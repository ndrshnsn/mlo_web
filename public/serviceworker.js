self.addEventListener("push", function(event) {
  var title = (event.data && event.data.text().split("||")[0]) || "Message from Commercial view";
  var body; body = event.data.text().split("||")[1];
  var tag = "mlo-notification-tag";
  var icon = '/mlo.png';

  event.waitUntil(
      self.registration.showNotification(title, {
          body: body,
          icon: icon,
          tag: tag
      })
  );
});