(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $(function() {
    var alerts, hideAlerts, slides;
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
    slides = $(".slide").removeClass("in");
    alerts = $(".page-alerts").on("click", function() {
      return $(this).removeClass("in");
    });
    setTimeout((function() {
      return slides.addClass("in");
    }), 1);
    hideAlerts = function() {
      return setTimeout((function() {
        if (alerts.is(":hover")) {
          return hideAlerts();
        } else {
          return alerts.removeClass("in");
        }
      }), 4000);
    };
    return hideAlerts();
  });

  App.Views.Refiddle = (function(_super) {
    __extends(Refiddle, _super);

    function Refiddle() {
      this.resizeTextGroup = __bind(this.resizeTextGroup, this);
      _ref = Refiddle.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Refiddle.prototype.events = {
      "click .save": function(e) {
        e.preventDefault();
        return this.form.submit();
      }
    };

    Refiddle.prototype.initialize = function(options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      Refiddle.__super__.initialize.apply(this, arguments);
      this.form = $("#refiddle-form");
      this.textGroup = $("#text");
      this.regexText = $("#refiddle_regex");
      this.corpusText = $("#refiddle_corpus_text");
      this.replaceText = $("#refiddle_replace_text");
      this.replaceResults = $("#replace_results");
      this.headerHeight = this.textGroup.find(".panel-heading").outerHeight();
      $(window).on("resize", function() {
        return _this.resizeTextGroup();
      });
      this.regexEditor = CodeMirror.fromTextArea(this.regexText[0]);
      this.regexEditor.on("viewportChange", this.resizeTextGroup);
      this.corpusEditor = CodeMirror.fromTextArea(this.corpusText[0], {
        lineWrapping: true,
        lineNumbers: true
      });
      this.replaceEditor = CodeMirror.fromTextArea(this.replaceText[0]);
      this.replaceEditor.on("viewportChange", this.resizeTextGroup);
      this.replaceEditor.refresh();
      this.resizeTextGroup();
      this.textGroup.find(".in").removeClass("in");
      return this.textGroup.find(".panel-collapse:first").addClass("in");
    };

    Refiddle.prototype.resizeTextGroup = function() {
      this.resizeTextGroupDebounced || (this.resizeTextGroupDebounced = _.debounce(this._resizeTextGroup, 50, true));
      return this.resizeTextGroupDebounced();
    };

    Refiddle.prototype._resizeTextGroup = function() {
      var availableHeight;
      if ($(window).width() >= 768) {
        availableHeight = $(window).height() - this.textGroup.offset().top - 15;
        this.corpusEditor.setSize(null, availableHeight - this.headerHeight * 2 - 5 - 5);
        return this.replaceResults.css({
          height: availableHeight - this.replaceText.outerHeight() - this.headerHeight * 2 - 5 - 5
        });
      } else {
        this.corpusEditor.setSize(null, "");
        return this.replaceResults.css({
          height: ""
        });
      }
    };

    return Refiddle;

  })(Backbone.View);

}).call(this);
