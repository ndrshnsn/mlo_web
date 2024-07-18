import { Controller } from "@hotwired/stimulus"
import "@js/base/multi"
import i18n from "@js/base/i18n"

export default class MultiController extends Controller {
  static values = { init: String, target: String, leftcolumn: { type: String, default: 'all' }, rightcolumn: { type: String, default: 'selected' } }

  connect() {
    const el = document.getElementById(this.element.id)
    const rightcolumn = i18n.t(this.rightcolumnValue)
    const leftcolumn = i18n.t(this.leftcolumnValue)

    if (this.targetValue == "") {
      $(el).multiSelect({
        cssClass: "form-control",
        escapeHTML: false,
        keepOrder: true,
        selectableHeader: "<div class='custom-header' data-id='"+ this.initValue +"' id='selectableH'>"+ leftcolumn +" ("+ this.initValue +")</div>",
        selectionHeader: "<div class='custom-header' id='selectionH'>"+ rightcolumn +" (0)</div>",
        afterSelect: function(values){
          $('#selectableH').text(''+ leftcolumn +' ('+ (parseInt($('#selectableH').attr('data-id')) - $('.ms-selected').length/2) +')');
          $('#selectionH').text(''+ rightcolumn +' ('+ $('.ms-selected').length/2 +')');
        },
        afterDeselect: function(values){
          $('#selectableH').text(''+ leftcolumn +' ('+ (parseInt($('#selectableH').attr('data-id')) - $('.ms-selected').length/2) +')');
          $('#selectionH').text(''+ rightcolumn +' ('+ $('.ms-selected').length/2 +')');
        }
      })
    }
  }

  selectall() {
    let tgt = document.getElementById(this.targetValue)
    $(tgt).multiSelect('select_all');
    return false;
  }

  deselectall() {
    let tgt = document.getElementById(this.targetValue)
    $(tgt).multiSelect('deselect_all');
    return false;
  }
}
