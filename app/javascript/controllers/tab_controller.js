import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  toggle() {
    let current = this.element
    let father = current.closest('ul').getElementsByTagName('a')

    for (var i = 0; i < father.length; i++) {
      father[i].classList.remove("active");
    }
    current.classList.add("active");
  }
}
