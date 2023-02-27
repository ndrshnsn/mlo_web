// LoadingOverlay
import LoadingOverlay from "gasparesganga-jquery-loading-overlay"
window.LoadingOverlay = LoadingOverlay

$.LoadingOverlaySetup({
  background      : "rgba(0, 0, 0, 0.5)",
  image           : "",
  fontawesome     : "ri ri-refresh-line",
  fontawesomeAnimation : "rotate_right",
  fontawesomeColor: "#ffffff",
  fontawesomeOrder: "1",
  minSize         : "25",
  maxSize         : "75"
});
