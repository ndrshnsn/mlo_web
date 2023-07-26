import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static values = { url: String }

  async send_it() {
    const url = this.urlValue
    const response = await post(url, {responseKind: "turbo-stream"})
  }
}
