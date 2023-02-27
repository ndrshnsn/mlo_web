import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    let backdrop = document.querySelector(".modal-backdrop");
    if (backdrop) {
      backdrop.remove();
    }
    this.modal = new bootstrap.Modal(this.element);
    this.modal.show();
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