// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require js.cookie
//= require browser_timezone_rails/set_time_zone
//= require zabuto_calendar.min
//= require_tree .

$(function () {
  $("a#go-pro-link").tooltip({ placement: "bottom", html: true });
});

$(".modal")
  .on("show", function () {
    $("body").addClass("modal-open");
  })
  .on("hidden", function () {
    $("body").removeClass("modal-open");
  });
