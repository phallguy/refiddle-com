$ ->
  $("a[href=\"#{location.hash}\"][data-toggle=tab]").tab('show')

  $('a[data-toggle="tab"][data-history=true]').on 'shown.bs.tab', (e) ->
    location.hash = $(e.target).attr('href').substr(1)

  $(".field_with_errors").first().each ->
    $f = $(this)
    $t = $f.closest(".tab-pane")
    if id = $t.attr("id")
      $("a[href=\"##{id}\"][data-toggle=tab]").tab('show')

  alerts = $(".page-alerts .alert.slide")
    .click( -> { debugger; $(this).removeClass("in") })
    .removeClass("in")

  setTimeout((-> alerts.addClass("in")),1)