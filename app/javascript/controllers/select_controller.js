import { Controller } from "@hotwired/stimulus"
import "@/base/select2"
import i18n from "@/base/i18n"

export default class SelectController extends Controller {
  static values = { 
    icon: Boolean,
    pholder: { type: String, default: 'all_items' },
    readonly: { type: Boolean, default: false },
    clear: { type: Boolean, default: true },
    search: { type: Boolean, default: false },
    close: { type: Boolean, default: true }
  }

  connect() {
    const el = document.getElementById(this.element.id)
    const searchOption = this.searchValue == false ? "Infinity" : 20
    if ( this.iconValue === true ) {
      this.select2withIcons(el, this.readonlyValue, i18n.t(this.pholderValue), searchOption, this.closeValue)
    } else {
      this.select2withoutIcons(el, this.readonlyValue, i18n.t(this.pholderValue), searchOption, this.closeValue)
    }
  }

  select2withIcons(element, setReadonly, pHolder, searchOption, closeOption) {
    $(element).select2({
      templateResult: this.formatResult,
      templateSelection: this.formatSelection,
      placeholder: pHolder,
      allowClear: this.clearValue,
      dropdownAutoWidth: true,
      width: '100%',
      minimumResultsForSearch: searchOption,
      closeOnSelect: closeOption,
      dropdownParent: $(element).parent()
    });

    if ( setReadonly === true ) {
      $(element).attr("readonly", "readonly");
    }
  }

  select2withoutIcons(element, setReadonly, pHolder, searchOption, closeOption) {
    $(element).select2({
      placeholder: pHolder,
      dropdownAutoWidth: true,
      width: '100%',
      allowClear: this.clearValue,
      closeOnSelect: closeOption,
      minimumResultsForSearch: searchOption,
      dropdownParent: $(element).parent()
    });

    if ( setReadonly === true ) {
      $(element).attr("readonly", "readonly");
    }
  }

  formatSelection(icon) {
    if (!icon.id) {
      return icon.text;
    }
  
    const originalOption = icon.element;
    const size = $(originalOption).data('img-size') || '14';
    const playerPosition = $(originalOption).data('position-value');
    const selectionFloat = $(originalOption).data('float') ? "style='float: right;'" : '';
    const playerClass = playerPosition ? 'avatar-md img-thumbnail rounded-circle' : '';
    const playerBadge = playerPosition
      ? '<span class="me-1 badge badge-'+ $(originalOption).data('position-class') +'">' + playerPosition + '</span>'
      : '';
  
    if (icon.id === '-') {
      var $icon = '<span class="d-flex align-items-center">' + icon.text + '</span>';
    } else if ($(originalOption).data('img')) {
      var $icon = '<span '+ selectionFloat +' class="d-flex align-items-center">' + playerBadge + '<img src="' + $(originalOption).data('img') + '" class="me-2 rounded-circle '+ playerClass +'" style="width: '+ size +'px; height: '+ size +'px;">'+ icon.text +'</span>';
    } else {
      var $icon = '<span>'+ playerBadge +'</span>';
    }

    $icon = $($icon);
    return $icon;
  }

  formatResult(icon) {
    if (!icon.id) {
      return icon.text;
    }
  
    const originalOption = icon.element;
    const size = $(originalOption).data('img-size') || '14';
    const playerPosition = $(originalOption).data('position-value');
    const playerClass = playerPosition ? 'avatar-md img-thumbnail rounded-circle' : '';
    const playerBadge = playerPosition
      ? '<span class="me-1 badge badge-'+ $(originalOption).data('position-class') +'">' + playerPosition + '</span>'
      : '';
  
    if (icon.id === '-') {
      var $icon = '<span class="d-flex align-items-center">' + icon.text + '</span>';
    } else if ($(originalOption).data('img')) {
      var $icon = '<span class="d-flex align-items-center">' + playerBadge + '<img src="' + $(originalOption).data('img') + '" class="me-2 rounded-circle '+ playerClass +'" style="width: '+ size +'px; height: '+ size +'px;">'+ icon.text +'</span>';
    } else {
      var $icon = '<span>'+ playerBadge +'</span>';
    }

    $icon = $($icon);
    return $icon;
  }

}
