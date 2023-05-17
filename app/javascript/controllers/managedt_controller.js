import { Controller } from "@hotwired/stimulus"

export default class ManagedtController extends Controller {
  clear_state() {
    sessionStorage.setItem('clearDTState', true)
  }
}






