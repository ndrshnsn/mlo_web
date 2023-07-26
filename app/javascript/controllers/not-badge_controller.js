import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static values = { url: String }

  async read_all() {
    const url = this.urlValue
    const response = await post(url, {responseKind: "turbo-stream"})
  }
}
