//import "./base/toastify"

$('#timeoutWarningModal').on('shown.bs.modal', function (e) {
  let dt = new Date();
  dt.setSeconds(dt.getSeconds() + 60);
  let sTime = ''+ dt.getFullYear() + '/'+ (dt.getMonth() + 1) + '/' + dt.getDate() + ' '+ dt.getHours() + ':'+ dt.getMinutes()  +':'+ dt.getSeconds() + '';
  $('#stimeleft').countdown(sTime, function(event) {
      $(this).html(event.strftime('%S'));
  });
})

document.querySelectorAll("form .auth-pass-inputgroup").forEach(function(s) {
  s.querySelectorAll(".password-addon").forEach(function(t) {
      t.addEventListener("click", function(t) {
          var e = s.querySelector(".password-input");
          "password" === e.type ? e.type = "text" : e.type = "password"
      })
  })
});