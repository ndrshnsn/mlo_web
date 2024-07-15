import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

let clocale = $('body').attr('data-locale').substring(0,2)
import { Portuguese } from 'flatpickr/dist/l10n/pt'
import { Spanish } from 'flatpickr/dist/l10n/es'

const langMap = {
  pt: Portuguese,
  es: Spanish,
  en: '',
}

if (clocale !== 'en') flatpickr.localize(langMap[clocale]);

export default class FlatpickrController extends Controller {
  static values = { ctype: String, sdate: { type: String, default: "false" }, edate: { type: String, default: "false" }, ddatei: { type: String, default: "false" }, ddatef: { type: String, default: "false" } }

  initialize() {
    const ctype = this.ctypeValue
    const rtype = this.rtypeValue
    const sdate = this.sdateValue
    const edate = this.edateValue
    let ddate = this.ddateValue

    if ( this.ddateiValue !== "false" ) {
      ddate = [''+ this.ddateiValue +'', ''+ this.ddatefValue +'']
    }
    
    switch(ctype) {
      case 'simple':
        flatpickr(this.element, {
          allowInput: true,
          altInput: true,
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
        flatpickr(this.element, {
          allowInput: true,
          altInput: true,
          mode: "range",
          altFormat: 'j M y',
          dateFormat: 'Y-m-d',
          defaultDate: ddate,
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




