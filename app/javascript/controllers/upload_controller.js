import { Controller } from "@hotwired/stimulus"

export default class UploadController extends Controller {
  static values = { img: String }

  connect() {
    const img = document.getElementById(this.imgValue)
    let accountUploadImg = $(img)
    let accountUploadBtn = $(this.element)
    if (accountUploadBtn) {
      accountUploadBtn.on('change', function (e) {
        let reader = new FileReader(), files = e.target.files
        reader.onload = function () {
          if (accountUploadImg) {
            accountUploadImg.attr('src', reader.result);
          }
        };
        reader.readAsDataURL(files[0]);
      });
    }
  }
}



