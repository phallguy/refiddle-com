(function() {
  $(function() {
    var alerts;
    $("a[href=\"" + location.hash + "\"][data-toggle=tab]").tab('show');
    $('a[data-toggle="tab"][data-history=true]').on('shown.bs.tab', function(e) {
      return location.hash = $(e.target).attr('href').substr(1);
    });
    $(".field_with_errors").first().each(function() {
      var $f, $t, id;
      $f = $(this);
      $t = $f.closest(".tab-pane");
      if (id = $t.attr("id")) {
        return $("a[href=\"#" + id + "\"][data-toggle=tab]").tab('show');
      }
    });
    alerts = $(".page-alerts .alert.slide").removeClass("in");
    return setTimeout((function() {
      return alerts.addClass("in");
    }), 1);
  });

}).call(this);
