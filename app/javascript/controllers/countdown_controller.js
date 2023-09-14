import { Controller } from "@hotwired/stimulus"
import Timer from "easytimer.js"

export default class CountdownController extends Controller {
  static values = {
    ignition: Array,
    after: { type: String, default: null},
  }

  connect() {
    const ignition = this.ignitionValue
    const el = this.element
    const timer = new Timer()

    timer.start({
      countdown: true,
      startValues: [0,0,0,2,0]
    })

    timer.addEventListener("secondsUpdated", function (e) {
      el.innerHTML =  timer.getTimeValues().toString()
    })
      
    timer.addEventListener('targetAchieved', function (e) {
      window.location.reload()
    })

  }
}
