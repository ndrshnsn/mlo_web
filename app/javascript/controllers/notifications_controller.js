import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class NotificationsController extends Controller {

  connect() {
    let checkbox = this.element
    checkbox.addEventListener('change', function () {
      checker(this.checked)
    })

    function checker(checked) {
      checked ? subscribe() : unsubscribe()
    }

    function promptForNotifications() {
      Notification.requestPermission()
      .then((permission) => {
        if (permission === "granted") {
          setupSubscription()
        } else {
          alert("Notifications declined")
        }
      })
      .catch(error => console.log("Notifications error", error))
    }

    function subscribe() {
      navigator.serviceWorker.register('/serviceworker.js')
      .then(function(registration) {
          return registration.pushManager.getSubscription()
        .then(function(subscription) {
          if (subscription) {
            return subscription;
          }
          return registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: window.vapidPublicKey
          });
        });
      }).then(function(subscription) {
        post(
          '/profile/notifications/subscribe', {
            body: {
              subscription: subscription.toJSON()
            },
            responseKind: "turbo-stream"
          }
        )
      });
    }
  
    function unsubscribe() {
      navigator.serviceWorker.ready
      .then((serviceWorkerRegistration) => {
        serviceWorkerRegistration.pushManager.getSubscription()
          .then((subscription) => {
            if ( subscription ) {
              subscription.unsubscribe()
                .then(function() {
                  post(
                    '/profile/notifications/unsubscribe', {
                      body: {
                        subscription: subscription.toJSON()
                      },
                      responseKind: "turbo-stream"
                    }
                  )
                })
                .catch((e) => {
                  logger.error('Error thrown while unsubscribing from push messaging', e);
                });
              }
          });
      });
    }
  }
}