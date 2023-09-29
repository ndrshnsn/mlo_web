function JsLoadingOverlay(action) {
  var overlay = document.getElementById("overlay");
  if (typeof(overlay) != 'undefined' && overlay != null) {
    switch(action) {
      case "show":
        overlay.style.display = "flex"
        break
      case "hide":
        overlay.style.display = "none"
        break
    }
  }
}
window.JsLoadingOverlay = JsLoadingOverlay
