import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const el = document.getElementById(this.element.id)
  }
}