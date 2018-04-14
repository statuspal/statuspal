import "../vendor/phoenix_html";
import "bootstrap-sass";
import "../vendor/jscolor";
import flatpickr from "flatpickr";

function PopupCenter(url, title, w, h) {
  // Fixes dual-screen position                         Most browsers      Firefox
  var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
  var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;

  var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ?
    document.documentElement.clientWidth : screen.width;
  var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ?
    document.documentElement.clientHeight : screen.height;

  var left = ((width / 2) - (w / 2)) + dualScreenLeft;
  var top = ((height / 2) - (h / 2)) + dualScreenTop;
  var newWindow = window.open(url, title, 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);

  // Puts focus on the newWindow
  if (window.focus) {
    newWindow.focus();
  }
}

function openTwitterAuthPopup() {
  var url = window.location.href.split('/status_pages')[0] +
    '/auth/request?status_page_id=' + $('.js-tweet-update').data('status-page-id');

  PopupCenter(url, 'Statushq -> Twitter Authorization', 700, 500);
}

$(function() {
  $(".datetime").flatpickr({
    enableTime: true,
    dateFormat: 'Y-m-dTH:i:S',
    altInput: true,
    altFormat: 'F j, Y h:i K',
    editable: true,
    allowInput: true,
    wrap: true
  });

  $('[data-toggle="tooltip"]').tooltip();

  if ($('.notification-fields').length > 0) {
    $('.js-tweet-update').change(function() {
      if ($(this).is(':checked') && $('.twitter-screen-name').text().trim() === '') {
        $(this).prop('checked', false);
        openTwitterAuthPopup();
      }
    });

    $('body').on('click', '.twitter-screen-name a', function(evt) {
      evt.preventDefault();
      openTwitterAuthPopup();
    });
  }

  if ($('.service-form').length > 0) {
    $('#service_monitoring_enabled').change(function () {
      var monitoringEnabled = $(this).is(':checked');
      $('.monitoring')
        .toggle(monitoringEnabled)
        .find('input').prop('disabled', !monitoringEnabled);
    });
  }
});
