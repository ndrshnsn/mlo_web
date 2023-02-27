import { Controller } from "@hotwired/stimulus"
import "@/base/select2"
import i18n from "@/base/i18n"

export default class SelectController extends Controller {
  static values = { icon: Boolean, pholder: { type: String, default: 'all_items' }, readonly: { type: Boolean, default: false } }

  connect() {
    const el = document.getElementById(this.element.id)
    if ( this.iconValue === true ) {
      this.select2withIcons(el, this.readonlyValue, i18n.t(this.pholderValue))
    } else {
      this.select2withoutIcons(el, this.readonlyValue, i18n.t(this.pholderValue))
    }
  }

  // Select2 with Icon Format
  select2withIcons(element, setReadonly, pHolder) {
    $(element).select2({
      templateResult: this.iconFormat,
      templateSelection: this.iconFormat,
      placeholder: pHolder,
      allowClear: true,
      dropdownAutoWidth: true,
      width: '100%',
      dropdownParent: $(element).parent()
    });

    if ( setReadonly === true ) {
      $(element).attr("readonly", "readonly");
    }
  }

  select2withoutIcons(element, setReadonly, pHolder) {
    $(element).select2({
      placeholder: pHolder,
      dropdownAutoWidth: true,
      width: '100%',
      allowClear: true,
      dropdownParent: $(element).parent()
    });

    if ( setReadonly === true ) {
      $(element).attr("readonly", "readonly");
    }
  }

  // Format icon
  iconFormat(icon) {
    if (!icon.id) {
      return icon.text;
    }
    var originalOption = icon.element;
    var $icon = '<span class="d-flex align-items-center"><img src="' + $(originalOption).data('img') + '" class="me-2", style="width: 14px; height: 14px;">' + icon.text + '</span>';
    $icon = $($icon);
    return $icon;
  }
}
