import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { autoshow: { type: Boolean, default: true }}

  connect() {
    const autoshow = this.autoshowValue
    
    let backdrop = document.querySelector(".modal-backdrop");
    if (backdrop) {
      backdrop.remove();
    }
    this.modal = new bootstrap.Modal(this.element);

    if (autoshow) {
      this.modal.show();
    }

    this.element.addEventListener('hidden.bs.modal', (event) => {
      this.element.remove();
    })
  }

  hideBeforeRender(event) {
    event.preventDefault()
    this.element.addEventListener('hidden.bs.modal', event.detail.resume)
    this.modal.hide()
  }
}