import { Controller } from "@hotwired/stimulus"
import { FetchRequest, post } from '@rails/request.js'

export default class extends Controller {
  static values = { url: String }

  connect() {
    const url = this.urlValue
    const select = document.getElementById(this.element.id)

    $(select).on("change", function (e) { 
      e.preventDefault()
      const request = new FetchRequest(
        "post", 
        url, 
        {
          body: JSON.stringify(
            {
              min_players: document.getElementById('season_min_players').value,
              max_players: document.getElementById('season_max_players').value,
              raffle_low_over: document.getElementById('season_raffle_low_over').value,
              raffle_high_over: document.getElementById('season_raffle_high_over').value
            }
          ),
          responseKind: "turbo-stream"
        }
      )
      const response = request.perform()
    });
  }
}
