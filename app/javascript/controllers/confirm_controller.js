import { Controller } from "@hotwired/stimulus"
import { navigator } from "@hotwired/turbo"
import "@/base/sweetalert2"
import i18n from "@/base/i18n"

export default class ConfirmController extends Controller {
  static values = { title: String, text: String, icon: String, link: String, action: { type: String, default: 'delete' }, turbo: { type: String, default: 'true'}, origin: { type: String, default: "false" } }

  dialog() {
    const title = this.titleValue
    const link = this.linkValue
    const text = this.textValue
    const icon = this.iconValue
    const action = this.actionValue
    const turbo = this.turboValue
    const origin = this.originValue
    const turboform = document.getElementById('turbo-xhref-form')
    const turbobutton = document.getElementById('turbo-xhref-button')

    Swal.fire({
      title: title,
      text: text,
      icon: icon,
      showCancelButton: !0,
      reverseButtons: true,
      customClass: {
        confirmButton: "btn btn-primary w-xs",
        cancelButton: "btn btn-outline-secondary w-xs me-2",
      },
      confirmButtonText: i18n.t('confirm'),
      cancelButtonText: i18n.t('cancel'),
      buttonsStyling: !1,
      showCloseButton: !0
    }).then((result) => {
        if (result.value) {
          turboform.setAttribute("action", link)
          turboform.setAttribute("method", action)
          if ( turbo === 'false' ) {
            turboform.setAttribute("data-turbo", "false")
          }
          if ( origin !== "false" ) {
            const url = new URL(window.location.href.split("?")[0])
            let newURL = url.origin + origin
            history.pushState({}, null, newURL)
            Turbo.navigator.history.replace(url.toString())
          }
          navigator.submitForm(turboform)
        } else {
          return false;
        }
    })
  }
}
