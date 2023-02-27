import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { theme: String }

  connect() {
    let el = $(this.element)
    let html = document.getElementsByTagName("HTML")[0];
    el.on('change.select2', function (e) {
      html.hasAttribute("data-layout-mode") && html.getAttribute("data-layout-mode") == "dark" ? 
        html.setAttribute("data-layout-mode", "light") :
        html.setAttribute("data-layout-mode", "dark");
    });
  }
}