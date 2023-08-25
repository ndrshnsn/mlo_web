import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    turbo: { type: Boolean, default: false },
    source: { type: String, default: "" },
    content: { type: String, default: "" },
    frame: { type: String, default: "" },
    id: Number
  }

  connect() {
    const popelement = document.getElementById(this.element.id)

    let popcontent = this.contentValue
    if ( this.turboValue == true ) {
      popcontent = `<turbo-frame id="${this.frameValue}" src='${this.sourceValue}' loading="lazy"></turbo-frame>`
    }
    
    const pop = new bootstrap.Popover(popelement, {
      container: 'body',
      trigger: 'focus',
      sanitize: false,
      placement: 'top',
      html: true,
      content: popcontent,
      delay: { hide: 200 }
    })
  }

  showPopover() {
    
    bootstrap.Popover.getInstance(popelement).show()
  }
}