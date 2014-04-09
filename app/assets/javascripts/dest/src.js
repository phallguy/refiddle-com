(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Flavors || (window.Flavors = {});

  Flavors.JavaScript = (function() {
    function JavaScript() {}

    JavaScript.prototype.match = function(pattern, corpus) {
      var matches, regex;
      matches = {
        matchSummary: {
          failed: 0,
          passed: 0,
          total: 0,
          tests: false
        }
      };
      if (!(regex = this.makeRegex(pattern))) {
        return matches;
      }
      if (!matches.matchSummary.tests) {
        this.matchWholeCorpus(regex, corpus, matches);
      }
      return matches;
    };

    JavaScript.prototype.makeRegex = function(pattern) {
      var e;
      try {
        return new RegExp(pattern.pattern, pattern.options);
      } catch (_error) {
        e = _error;
        console.log("Oops, invalid regex " + e);
        return null;
      }
    };

    JavaScript.prototype.matchWholeCorpus = function(regex, corpus, matches) {
      var match, mx, pair;
      mx = 0;
      while (match = regex.exec(corpus)) {
        pair = [match.index, match[0].length];
        matches[mx.toString()] = pair;
        matches.matchSummary.total++;
        if (!regex.global) {
          return;
        }
        mx++;
        if (mx > corpus.length * 2) {
          break;
        }
        if (regex.lastIndex >= corpus.length) {
          break;
        }
      }
    };

    return JavaScript;

  })();

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
      this.highlightMatches = __bind(this.highlightMatches, this);
      this.updateMatches = __bind(this.updateMatches, this);
      _ref = Refiddle.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Refiddle.prototype.literalRegex = /^\/[^\/]+\/\w*/m;

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
      this.flavor = new Flavors.JavaScript();
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
      this.regexEditor.on("changes", this.updateMatches);
      this.corpusEditor = CodeMirror.fromTextArea(this.corpusText[0], {
        lineWrapping: true,
        lineNumbers: true
      });
      this.corpusEditor.on("changes", this.updateMatches);
      this.replaceEditor = CodeMirror.fromTextArea(this.replaceText[0]);
      this.replaceEditor.on("viewportChange", this.resizeTextGroup);
      this.replaceEditor.refresh();
      this.resizeTextGroup();
      this.textGroup.find(".in").removeClass("in");
      this.textGroup.find(".panel-collapse:first").addClass("in");
      return this.updateMatches();
    };

    Refiddle.prototype.getPattern = function() {
      return this.parsePattern(this.regexEditor.getValue());
    };

    Refiddle.prototype.parsePattern = function(pattern, options) {
      var ix, ops, parsed;
      parsed = {
        pattern: pattern,
        options: options || "",
        lteral: false
      };
      if (this.literalRegex.test(pattern)) {
        ix = pattern.lastIndexOf('/');
        ops = pattern.substring(ix + 1);
        parsed.pattern = pattern.substring(1, ix).replace('\\/', '/');
        parsed.options = ops;
        parsed.literal = true;
      }
      parsed.global = parsed.options.indexOf('g') > -1;
      return parsed;
    };

    Refiddle.prototype.getCorpus = function() {
      return this.corpusEditor.getValue();
    };

    Refiddle.prototype.updateMatches = function() {
      this.matches = this.flavor.match(this.getPattern(), this.getCorpus());
      return this.highlightMatches(this.matches);
    };

    Refiddle.prototype.highlightMatches = function(matches) {
      var from, index, pair, to;
      _.each(this.corpusEditor.getAllMarks(), function(m) {
        return m.clear();
      });
      for (index in matches) {
        pair = matches[index];
        if (index === "matchSummary") {
          continue;
        }
        from = this.corpusEditor.doc.posFromIndex(pair[0]);
        to = this.corpusEditor.doc.posFromIndex(pair[0] + pair[1]);
        this.corpusEditor.markText(from, to, {
          className: "match"
        });
      }
      return void 0;
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
