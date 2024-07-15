import { Controller } from "@hotwired/stimulus"
import "@/base/parsley"
import "@/base/sweetalert2"
import i18n from "@/base/i18n"

export default class FormController extends Controller {
  static values = {
    title: String,
    text: String,
    icon: { type: String, default: "question" },
    scroll: Boolean,
    swal: { type: Boolean, default: true },
    modal: { type: String, default: "" },
    redirect: { type: String, default: "" }
  }

  connect() {
    const form = document.getElementById(this.element.id)
    const title = this.titleValue
    const text = this.textValue
    const icon = this.iconValue
    const scrollTop = this.scrollValue
    const redirect = this.redirectValue
    const swal = this.swalValue
    const modal = document.getElementById(this.modalValue)

    let scrollVar = scrollTop

    if (redirect) {
      this.element.addEventListener("turbo:submit-end", (event) => {
        const url = new URL(window.location.href.split("?")[0])
        history.pushState({}, null, redirect)
        Turbo.navigator.history.replace(url.toString())
      })
    }

    $(form).parsley();
    $(form).parsley().on('form:submit', function (formInstance) {
      if ( swal === true ) {
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
          showCloseButton: !0,
          didClose: () => {
            if (scrollTop === true && scrollVar === scrollTop ) {
              scrollTopFunction()
            }
          }
        }).then((result) => {
            if (result.value) {
              scrollVar = true
              $('.modal').modal('hide')
              $('.modal-backdrop').remove()
              $(form).parsley().destroy()
              form.requestSubmit()
            } else {
              scrollVar = false
              return false;
            }
        })
      } else {
        scrollVar = true
        if ( modal !== "" ) {
          $(modal).modal('toggle')
        } else {
          $('.modal').modal('toggle')
          $('.modal-backdrop').remove()
        }
        $(form).parsley().destroy()
        Turbo.navigator.submitForm(form)
      }
      return false;
    });
  }
}
