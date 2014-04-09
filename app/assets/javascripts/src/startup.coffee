$ ->
  $("a[href=\"#{location.hash}\"][data-toggle=tab]").tab('show')

  $('a[data-toggle="tab"][data-history=true]').on 'shown.bs.tab', (e) ->
    location.hash = $(e.target).attr('href').substr(1)

  $(".field_with_errors").first().each ->
    $f = $(this)
    $t = $f.closest(".tab-pane")
    if id = $t.attr("id")
      $("a[href=\"##{id}\"][data-toggle=tab]").tab('show')

  slides = $(".slide")
    .removeClass("in")

  alerts = $(".page-alerts")
    .on "click", -> 
      $(this).removeClass("in")

  setTimeout((-> slides.addClass("in")),1)
  hideAlerts = ->
    setTimeout((-> if alerts.is(":hover") then hideAlerts() else alerts.removeClass("in") ), 4000)
  hideAlerts()