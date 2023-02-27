import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

let clocale = $('body').attr('data-locale').substring(0,2)
import * as locale from 'flatpickr/dist/l10n/'+ clocale +'.js'

export default class FlatpickrController extends Controller {
  static values = { ctype: String, sdate: { type: String, default: "false" }, edate: { type: String, default: "false" } }

  initialize() {
    const ctype = this.ctypeValue
    const rtype = this.rtypeValue
    const sdate = this.sdateValue
    const edate = this.edateValue
  
    switch(ctype) {
      case 'simple':
        flatpickr(this.element, {
          allowInput: true,
          altInput: true,
          locale: clocale,
          altFormat: 'j M y',
          dateFormat: 'Y-m-d',
          onReady: function (selectedDates, dateStr, instance) {
            if (instance.isMobile) {
                $(instance.mobileInput).attr('step', null);
            }
          },
          onOpen: function(selectedDates, dateStr, instance) {
              $(instance.altInput).prop('readonly', true);
          },
          onClose: function(selectedDates, dateStr, instance) {
              $(instance.altInput).prop('readonly', false);
              $(instance.altInput).blur();
          }
        });
        break

      case 'range':
        console.log(clocale)
        flatpickr(this.element, {
          allowInput: true,
          altInput: true,
          mode: "range",
          locale: clocale,
          altFormat: 'j M y',
          dateFormat: 'Y-m-d',
          minDate: sdate,
          maxDate: edate,
          onReady: function (selectedDates, dateStr, instance) {
            if (instance.isMobile) {
                $(instance.mobileInput).attr('step', null);
            }
          },
          onOpen: function(selectedDates, dateStr, instance) {
              $(instance.altInput).prop('readonly', true);
          },
          onClose: function(selectedDates, dateStr, instance) {
              $(instance.altInput).prop('readonly', false);
              $(instance.altInput).blur();
          }
        });
        break
    }
  }
}





