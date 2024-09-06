document.addEventListener("DOMContentLoaded", function (event) {
  JsLoadingOverlay("hide")
});

document.addEventListener("shown.bs.modal", function (event) {
  JsLoadingOverlay("hide")
});

document.addEventListener("hidden.bs.modal", function (event) {
  $('.popover').remove()
});

document.addEventListener("show.bs.popover", function (event) {
  window.preserve_scroll = true
});

document.addEventListener("turbo:click", function (event) {
  JsLoadingOverlay("show")
  $('.popover').remove()
});

document.addEventListener("turbo:visit", function (event) {
  JsLoadingOverlay("hide")
});

document.addEventListener("turbo:frame-render", function (event) {
  if (typeof window.preserve_scroll === 'undefined' || window.preserve_scroll === null) {
    scrollTopFunction()
  } else {
    delete window.preserve_scroll
  }
  JsLoadingOverlay("hide")
});

document.addEventListener("turbo:load", function (event) {
  JsLoadingOverlay("hide")
});

document.addEventListener("turbo:submit-start", function (event) {
  JsLoadingOverlay("show")
});

document.addEventListener("turbo:submit-end", function (event) {
  JsLoadingOverlay("hide")
});

// document.addEventListener("turbo:frame-missing", (event) => {
//   const { detail: { response, visit } } = event;
//   event.preventDefault();
//   visit(response.url);
// });

// if (window.history.state && window.history.state.turbo) {
//   window.addEventListener("popstate", function () { location.reload(true); });
// }
