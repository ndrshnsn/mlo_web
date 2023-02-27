import { Controller } from "@hotwired/stimulus"
import Stepper from 'bs-stepper'

export default class extends Controller {
  static values = { theme: String }

  connect() {
    var bsStepper = $(this.element)
    var stepper = new Stepper($(bsStepper)[0])
    var horizontalWizard = document.querySelector('.horizontal-wizard')
    var numberedStepper = new Stepper(horizontalWizard)

    if (typeof bsStepper !== undefined && bsStepper !== null) {
      for (var el = 0; el < bsStepper.length; ++el) {
        bsStepper[el].addEventListener('show.bs-stepper', function (event) {
          var index = event.detail.indexStep;
          var numberOfSteps = $(event.target).find('.step').length - 1;
          var line = $(event.target).find('.step');
  
          for (var i = 0; i < index; i++) {
            line[i].classList.add('crossed');
  
            for (var j = index; j < numberOfSteps; j++) {
              line[j].classList.remove('crossed');
            }
          }
          if (event.detail.to == 0) {
            for (var k = index; k < numberOfSteps; k++) {
              line[k].classList.remove('crossed');
            }
            line[0].classList.remove('crossed');
          }
        });
      }
    }

    $('.btn-next').on('click', function (e) {
      e.preventDefault();
      numberedStepper.next();
    });
  
    $('.btn-prev').on('click', function (e) {
      e.preventDefault();
      numberedStepper.previous();
    });

  }
}