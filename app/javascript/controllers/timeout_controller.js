import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { frequency: String, tpath: String, apath: String, warning: String, modal: String }

  connect() {
    const frequency = this.frequencyValue
    const apath = this.apathValue
    const tpath = this.tpathValue
    const warning = this.warningValue
    const modal = this.modalValue

    setTimeout(periodicalQuery, (frequency * 1000))

    function periodicalQuery() {
      var request = new XMLHttpRequest();
      request.onload = function (event) {
        var status = event.target.status
        var response = event.target.response
        if (status === 200 && (response === false || response === 'false' || response === null)) {
          window.location.href = tpath
        }
      }
      request.open('GET', apath, true)
      request.responseType = 'json'
      request.onload = function(e) {
        if (this.status == 200) {
          let modal_el = document.getElementById(modal)
          if (new Date(this.response.timeout).getTime() < (new Date().getTime() + warning * 1000)) {
            if (!modal_el.classList.contains('show')) {
              let show_modal = new bootstrap.Modal(modal_el)
              show_modal.show()
            }
          }
        }
      };
      request.send();
      setTimeout(periodicalQuery, (frequency * 1000))
    }
  }
}