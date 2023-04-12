import { Controller } from "@hotwired/stimulus"
//import { navigator } from "@hotwired/turbo"
import "@/base/parsley"
import "@/base/sweetalert2"
import i18n from "@/base/i18n"

export default class FormController extends Controller {
  static values = { title: String, text: String, icon: String, scroll: Boolean }

  connect() {
    const form = document.getElementById(this.element.id);
    const title = this.titleValue
    const text = this.textValue
    const icon = this.iconValue
    const scrollTop = this.scrollValue
    let scrollVar = scrollTop

    $(form).parsley();
    $(form).parsley().on('form:submit', function (formInstance) {
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
      return false;
    });
  }
}
