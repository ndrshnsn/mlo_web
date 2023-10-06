import { Controller } from "@hotwired/stimulus"
import "@/base/select2"
import i18n from "@/base/i18n"

export default class SelectController extends Controller {
  static values = { 
    icon: Boolean,
    pholder: { type: String, default: 'all_items' },
    readonly: { type: Boolean, default: false },
    clear: { type: Boolean, default: true },
    search: { type: Boolean, default: false }
  }

  connect() {
    const el = document.getElementById(this.element.id)
    const searchOption = this.searchValue == false ? "Infinity" : 20
    if ( this.iconValue === true ) {
      this.select2withIcons(el, this.readonlyValue, i18n.t(this.pholderValue), searchOption)
    } else {
      this.select2withoutIcons(el, this.readonlyValue, i18n.t(this.pholderValue), searchOption)
    }
    // $(el).on('select2:select', function () {
    //   let event = new Event('change', { bubbles: true }) // fire a native event
    //   this.dispatchEvent(event);
    // })
  }

  select2withIcons(element, setReadonly, pHolder, searchOption) {
    $(element).select2({
      templateResult: this.iconFormat,
      templateSelection: this.iconFormat,
      placeholder: pHolder,
      allowClear: this.clearValue,
      dropdownAutoWidth: true,
      width: '100%',
      minimumResultsForSearch: searchOption,
      dropdownParent: $(element).parent()
    });

    if ( setReadonly === true ) {
      $(element).attr("readonly", "readonly");
    }
  }

  select2withoutIcons(element, setReadonly, pHolder, searchOption) {
    $(element).select2({
      placeholder: pHolder,
      dropdownAutoWidth: true,
      width: '100%',
      allowClear: this.clearValue,
      minimumResultsForSearch: searchOption,
      dropdownParent: $(element).parent()
    });

    if ( setReadonly === true ) {
      $(element).attr("readonly", "readonly");
    }
  }

  iconFormat(icon) {
    if (!icon.id) {
      return icon.text;
    }
    let originalOption = icon.element;
    let size = $(originalOption).data('img-size') == null ? "14" : $(originalOption).data('img-size')
    let player_position = ''
    let player_class = ''

    if ( $(originalOption).data('position-value') ) {
      player_position = '<span class="me-1 badge badge-' + $(originalOption).data('position-class') + '">' + $(originalOption).data('position-value') + '</span>'
      player_class = "avatar-md img-thumbnail rounded-circle"
    }

    if ( icon.id == "-" ) {
      var $icon = '<span class="d-flex align-items-center">' + icon.text + '</span>'
    } else {
      if ( $(originalOption).data('img') ) {
        var $icon = '<span class="d-flex align-items-center">' + player_position + '<img src="' + $(originalOption).data('img') + '" class="me-2 rounded-circle '+ player_class +'", style="width: ' + size + 'px; height: ' + size + 'px;">' + icon.text + '</span>'
      } else {
        var $icon = '<span>' + player_position + '</span>'
      }
    }

    $icon = $($icon);
    return $icon;
  }
}
