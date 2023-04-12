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
  $('.popover').remove();
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

