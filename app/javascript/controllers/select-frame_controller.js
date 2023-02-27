import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { target: String }

  connect() {
    const frame = document.getElementById(this.targetValue);

    let select = $(this.element)
    select.on('select2:select', function (e) {
      var newSrc = $(e.params.data.element).data('src')
      frame.src = newSrc
      frame.reload()
    });
  }
}