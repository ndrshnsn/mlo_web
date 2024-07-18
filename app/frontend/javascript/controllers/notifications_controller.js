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
    
    function subscribe() {
      if (navigator.serviceWorker) {
        Notification.requestPermission()
        .then((permission) => {
          if (permission === "granted") {
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
                '/notifications/subscribe', {
                  body: {
                    subscription: subscription.toJSON()
                  },
                  responseKind: "turbo-stream"
                }
              )
            })
          } else {
            alert("Notifications declined")
          }
        })
        .catch(error => console.log("Notifications error", error))
      }
    }
 
    function unsubscribe() {
      navigator.serviceWorker.ready
      .then((serviceWorkerRegistration) => {
        serviceWorkerRegistration.pushManager.getSubscription()
          .then((subscription) => {
            if ( subscription ) {
              unregister()
              subscription.unsubscribe()
                .then(function() {
                  post(
                    '/notifications/unsubscribe', {
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

    function unregister() {
      navigator.serviceWorker.getRegistrations()
      .then(registrations => {
        registrations.forEach(registration => {
          registration.unregister();
        })
      });

      navigator.serviceWorker.getRegistrations().then(function(registrations) {
      for(let registration of registrations) {
        registration.unregister()
      } })

      if(window.navigator && navigator.serviceWorker) {
        navigator.serviceWorker.getRegistrations()
        .then(function(registrations) {
          for(let registration of registrations) {
            registration.unregister();
          }
        });
      }

      if ('caches' in window) {
        caches.keys()
          .then(function(keyList) {
              return Promise.all(keyList.map(function(key) {
                  return caches.delete(key);
              }));
          })
      }

      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistrations().then(function (registrations) {
          for (const registration of registrations) {
            // unregister service worker
            console.log('serviceWorker unregistered');
            registration.unregister();

            setTimeout(function(){
              console.log('trying redirect do');
              window.location.replace(window.location.href); // because without redirecting, first time on page load: still service worker will be available
            }, 3000);
          }
        });
      }
    }
  }



}