import { Controller } from "@hotwired/stimulus"
import SimpleBar from "simplebar"

export default class extends Controller {
  static values = { el: String }

  connect() {
    new SimpleBar(document.getElementById(this.elValue), {
      autoHide: false,
      forceVisible: true
    });
  }
}
