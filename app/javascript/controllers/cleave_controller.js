import { Controller } from "@hotwired/stimulus"
import Cleave from "cleave.js"

export default class CleaveController extends Controller {
  static values = { ctype: String }

  initialize() {
    const ctype = this.ctypeValue
  
    switch(ctype) {
      case 'phone':
        new Cleave(this.element, {
          numericOnly: true,
          blocks: [0, 2, 5, 4],
          delimiters: ["(", ") ", "-"]
        });
        break
      case 'uppercase':
        new Cleave(this.element, {
          blocks: [99999],
          delimiter: '',
          uppercase: true
        });
        break
      case 'price':
        new Cleave(this.element, {
          numeral: true,
          numeralThousandsGroupStyle: 'thousand'
        });
      case 'numerical':
        new Cleave(this.element, {
          numericOnly: true,
          blocks: [99999]
        });
    }
  }
}
