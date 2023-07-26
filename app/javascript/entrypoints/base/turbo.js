document.addEventListener("DOMContentLoaded", function(event) { 
  $.LoadingOverlay("hide", "force")
});

document.addEventListener("shown.bs.modal", function (event) {
  $.LoadingOverlay("hide", "force")
});

document.addEventListener("hidden.bs.modal", function (event) {
  $.LoadingOverlay("hide", "force")
});

document.addEventListener("hide.bs.modal", function (event) {
  $.LoadingOverlay("show")
});

document.addEventListener("turbo:click", function(event) {
  $.LoadingOverlay("show")
  $('.popover').remove()
});

document.addEventListener("turbo:visit", function(event) { 
  $.LoadingOverlay("hide", "force")
});

document.addEventListener("turbo:frame-render", function(event) { 
  $.LoadingOverlay("hide", "force")
});

document.addEventListener("turbo:load", function(event) {
  $.LoadingOverlay("hide", "force")
});

document.addEventListener("turbo:submit-start", function(event) { 
  $.LoadingOverlay("show")
});

document.addEventListener("turbo:submit-end", function(event) { 
  $.LoadingOverlay("hide", "force")
});

// document.addEventListener("turbo:frame-missing", (event) => {
//   const { detail: { response, visit } } = event;
//   event.preventDefault();
//   visit(response.url);
// });

// if (window.history.state && window.history.state.turbo) {
//   window.addEventListener("popstate", function () { location.reload(true); });
// }
