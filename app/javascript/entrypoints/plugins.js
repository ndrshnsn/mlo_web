document.querySelectorAll("form .auth-pass-inputgroup").forEach(function(s) {
  s.querySelectorAll(".password-addon").forEach(function(t) {
      t.addEventListener("click", function(t) {
          var e = s.querySelector(".password-input");
          "password" === e.type ? e.type = "text" : e.type = "password"
      })
  })
});