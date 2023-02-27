import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { father: String, child: String }

  toggle() {
    let prevFather = sessionStorage.getItem('sidebarFather') ? sessionStorage.getItem('sidebarFather') : null
    let prevChild = sessionStorage.getItem('sidebarChild') ? sessionStorage.getItem('sidebarChild') : null

    // Disable Previous sidebar Items
    if ( prevChild !== null && document.getElementById(prevChild)) {
      document.getElementById(prevChild).classList.remove("active");
    }

    // Add Open Class to Father dropdown
    if ( this.fatherValue !== null && document.getElementById(prevFather)) {
      if ( ( this.fatherValue !== prevFather ) && ( prevFather !== null ) ) {
        document.getElementById(prevFather).setAttribute("aria-expanded", false);
        document.getElementById(prevFather).classList.remove("active");
        if (document.getElementById(prevFather + "_collapse")) {
          document.getElementById(prevFather + "_collapse").classList.remove("show");
          document.getElementById(prevFather + "_collapse").classList.remove("active");
        }
      }
      sessionStorage.setItem('sidebarFather', this.fatherValue)
      if ( this.fatherValue !== "" ) {
        document.getElementById(this.fatherValue).setAttribute("aria-expanded", true)
      }
    }

    // Add Active class to child
    if ( this.childValue !== "" ) {
      document.getElementById(this.childValue).classList.add("active")
    }

    // Save into SessionStorage
    sessionStorage.setItem('sidebarChild', this.childValue)

		//For collapse vertical menu
    var windowSize = document.documentElement.clientWidth;
    if (windowSize <= 767) {
      document.body.classList.remove("vertical-sidebar-enable");
      document.documentElement.setAttribute("data-sidebar-size", "lg");
    }
  }
}