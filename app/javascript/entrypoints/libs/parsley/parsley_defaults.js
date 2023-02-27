// Parsley
var token = $('meta[name=csrf-token]').attr('content');

$.extend(window.Parsley.options, {
    errorClass: 'error',
    successClass: 'valid',
    classHandler: function (ParsleyField) { return ParsleyField.$element; },
    errorsWrapper: '<div class="invalid-feedback"></div>', errorTemplate: '<div></div>'
});
window.Parsley.setLocale($(document.body).attr("data-locale"));
window.Parsley.on('field:error', function (fieldInstance) {
    var messages = fieldInstance.getErrorsMessages();
    if ( fieldInstance.$element.hasClass('select2') || fieldInstance.$element.hasClass('multi') ) {
        var targetElement = $('#popover_' + fieldInstance.$element.attr('id'))
    } else {
        var targetElement = fieldInstance.$element
    }

    targetElement.popover('dispose');
    targetElement.popover({
        trigger: 'manual',
        container: 'body',
        placement: 'top',
        fallbackPlacement: ['top', 'top', 'top', 'top'],
        content: function () {
            return messages[0];
        }
    }).popover('toggle');
    // console.log('Validation failed for: ', 
    //       this.$element.attr('name'));
});

window.Parsley.on('field:success', function (fieldInstance) {
    if ( fieldInstance.$element.hasClass('select2') ) {
        $('#popover_' + fieldInstance.$element.attr('id')).popover('dispose');
    } else {
        fieldInstance.$element.popover('dispose');
    }
});

window.Parsley.on('form:validate', function ( form ) {
  if (!form.isValid()){
      $("html,body").animate({
          scrollTop : 0
      });
  }
  
  if (form.$element.is(":hidden")) {
      form._ui.$errorsWrapper.css('display', 'none');
      form.validationResult = true;
      return true;
  }
});

//has uppercase
window.Parsley.addValidator('uppercase', {
  requirementType: 'number',
  validateString: function(value, requirement) {
    var uppercases = value.match(/[A-Z]/g) || [];
    return uppercases.length >= requirement;
  },
  messages: {
    en: 'Your password must contain at least (%s) uppercase letter.'
  }
});

//has lowercase
window.Parsley.addValidator('lowercase', {
  requirementType: 'number',
  validateString: function(value, requirement) {
    var lowecases = value.match(/[a-z]/g) || [];
    return lowecases.length >= requirement;
  },
  messages: {
    en: 'Your password must contain at least (%s) lowercase letter.'
  }
});
  
//has number
window.Parsley.addValidator('number', {
  requirementType: 'number',
  validateString: function(value, requirement) {
    var numbers = value.match(/[0-9]/g) || [];
    return numbers.length >= requirement;
  },
  messages: {
    en: 'Your password must contain at least (%s) number.'
  }
});
  
//has special char
window.Parsley.addValidator('special', {
  requirementType: 'number',
  validateString: function(value, requirement) {
    var specials = value.match(/[^a-zA-Z0-9]/g) || [];
    return specials.length >= requirement;
  },
  messages: {
    en: 'Your password must contain at least (%s) special characters.'
  }
});