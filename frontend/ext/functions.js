function invertDict (obj) {

  var new_obj = {};

  for (var prop in obj) {
    if(obj.hasOwnProperty(prop)) {
      new_obj[obj[prop]] = prop;
    }
  }

  return new_obj;
};

function moveCaretAtEnd(e) {
  var temp_value = e.target.value
  e.target.value = ''
  e.target.value = temp_value
}

function objectValues(obj) {
  var result = [];
  Object.keys(obj).forEach(function(key) {
    result.push(obj[key]);
  })
  return result;
}

const pick = (obj, keys) => 
  Object.keys(obj)
    .filter(i => keys.includes(i))
    .reduce((acc, key) => {
      acc[key] = obj[key];
      return acc;
    }, {});

function radioCheckBoxes(jQuery) {
  let $ = jQuery
  $("input:checkbox").on('click', function() {
    // in the handler, 'this' refers to the box clicked on
    var $box = $(this);
    if ($box.is(":checked")) {
      // the name of the box is retrieved using the .attr() method
      // as it is assumed and expected to be immutable
      var group = "input:checkbox[name='" + $box.attr("name") + "']";
      // the checked state of the group/box on the other hand will change
      // and the current value is retrieved using .prop() method
      $(group).prop("checked", false);
      $box.prop("checked", true);
    } else {
      $box.prop("checked", false);
    }
  });
}

function grabCsrfToken(jQuery) {
  let $ = jQuery;
  return $('meta[name="csrf-token"]').attr('content')
}

function isURL(str) {
  var expression = /[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi;
  var pattern = new RegExp(expression);
  return pattern.test(str);
}

function injectAuthenticityToken(jQuery, cssSelector) {
  let token = grabCsrfToken(jQuery);
  jQuery(cssSelector).val(token);
};

function scrollToHash(hash, jQuery) {
  if (hash) {
    var container = jQuery('body'),
        scrollTo = jQuery(hash);

    container.scrollTop(
        scrollTo.offset().top - container.offset().top + container.scrollTop()
    );
  }
}

function addCommasToNum(val) {
  if (val == 0) return '0';
  
  let result = val ? val.toString().replace(/[^0-9\.]/g, "") : null;
  result = result ? numberWithCommas(parseFloat(parseInt(result))) :  null;
  return result;
}

function hex(n){
 n = n || 16;
 var result = '';
 while (n--){
  result += Math.floor(Math.random()*16).toString(16).toUpperCase();
 }
 return result;
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function validateEmail(email) {
    var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

function decimalToPercent(dec) {
  if (dec) {
    return (Math.round(dec*1000))/10.0.toString() + '%';
  } else {
    return null
  }
}

function setFileUpload(jQuery, doneCallback) {
  let $ = jQuery
  
  $(function () {
      'use strict';
      // Change this to the location of your server-side upload handler:
      var url = window.location.hostname === 'blueimp.github.io' ?
                  '//jquery-file-upload.appspot.com/' : '/api/images/upload';
                  
      $('#fileupload').fileupload({
          url: url,
          dataType: 'json',
          acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
          disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent),
          imageMaxWidth: 400,
          imageMaxHeight: 800,
          done: function (e, data) {
            doneCallback && doneCallback(data.result.url);
          },
          progressall: function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('#progress .progress-bar').css('width', progress + '%');
          },
          fail: function(e, data) {
            alert('There was an error. Please check the file you are uploading.')
          }
      }).prop('disabled', !$.support.fileInput)
          .parent().addClass($.support.fileInput ? undefined : 'disabled');
  });
}

export { 
  invertDict, 
  radioCheckBoxes, 
  grabCsrfToken, 
  injectAuthenticityToken, 
  setFileUpload, 
  objectValues,
  scrollToHash, validateEmail,
  addCommasToNum, decimalToPercent,
  pick, hex, isURL,
  moveCaretAtEnd }