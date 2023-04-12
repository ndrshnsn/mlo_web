$('#timeoutWarningModal').on('shown.bs.modal', function (e) {
  //var timer = new easytimer.Timer();
  timer.start({countdown: true, startValues: {seconds: 30}});
  $('#stimeleft').html(timer.getTimeValues().toString(['minutes', 'seconds']));

  timer.addEventListener('secondsUpdated', function (e) {
    $('#stimeleft').html(timer.getTimeValues().toString(['minutes', 'seconds']));
  });

  timer.addEventListener('targetAchieved', function (e) {
    window.location.reload();
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