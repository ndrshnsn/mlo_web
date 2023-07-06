import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    plusbutton: String,
    minusbutton: String
  }

  connect() {
    const input = document.getElementById(this.element.id)
    const plus = document.getElementById(this.plusbuttonValue)
    const minus = document.getElementById(this.minusbuttonValue)
    
    if (plus) {
      plus.addEventListener('click', function (event) {
        if (parseInt(input.value) < input.getAttribute('max')) {
          input.value = parseInt(input.value) + parseInt(input.getAttribute('step'))
        }
      });
    }

    if (minus) {
      minus.addEventListener('click', function (event) {
        if (parseInt(input.value) > input.getAttribute('min')) {
          input.value = parseInt(input.value) - parseInt(input.getAttribute('step'))
        }
      });
    }
  }
}


