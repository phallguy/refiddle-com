(function() {
  var CorpusTokenizer, Matcher, NegativeMatcher, PositiveMatcher, RegexReplaceTokenizer, RegexTokenizer, _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  CorpusTokenizer = (function() {
    function CorpusTokenizer() {}

    CorpusTokenizer.prototype.tokenize = function(stream) {
      var ch, sol;
      this.state || (this.state = this._plain);
      sol = stream.sol();
      ch = stream.next();
      if (sol && ch === '#') {
        return this.changeState(stream);
      } else {
        return this.state(stream, ch);
      }
    };

    CorpusTokenizer.prototype.changeState = function(stream) {
      this.state = (function() {
        switch (stream.peek()) {
          case "+":
            return this._operator;
          case "-":
            return this._operator;
          case "#":
            return this._comment;
        }
      }).call(this);
      return "bracket";
    };

    CorpusTokenizer.prototype._operator = function(stream, ch) {
      switch (ch) {
        case "+":
        case "-":
          return "operator";
        case '#':
          this.state = this._comment;
          stream.skipToEnd();
          return "comment";
        default:
          stream.skipToEnd();
          this.state = this._plain;
          return "header";
      }
    };

    CorpusTokenizer.prototype._comment = function(stream) {
      stream.skipToEnd();
      return "comment";
    };

    CorpusTokenizer.prototype._plain = function(stream) {
      stream.skipToEnd();
      return null;
    };

    return CorpusTokenizer;

  })();

  CodeMirror.defineMode('corpus', function() {
    return {
      startState: function() {
        return new CorpusTokenizer;
      },
      token: function(stream, state) {
        return state.tokenize(stream);
      }
    };
  });

  RegexTokenizer = (function() {
    function RegexTokenizer() {}

    RegexTokenizer.prototype.tokenize = function(stream) {
      var ch;
      this.state || (this.state = this._start);
      ch = stream.next();
      if (ch === '\\') {
        stream.next();
        return "quote";
      } else {
        return this.state(stream, ch);
      }
    };

    RegexTokenizer.prototype._comment = function(stream) {
      return "comment";
    };

    RegexTokenizer.prototype._plain = function(stream, ch) {
      switch (ch) {
        case '/':
          this.state = this._options;
          return "qualifier";
        case "[":
          this.entering = true;
          this.ccDepth = 0;
          this.state = this._characterClass;
          return "meta";
        case "(":
          this.entering = true;
          this.state = this._group;
          return "bracket";
        case ")":
          return "bracket";
        case "{":
          if (stream.skipTo('}')) {
            stream.next();
          }
          return "tag";
        case ".":
        case "*":
        case "?":
        case '|':
          return "operator";
        case "^":
        case "$":
          return "atom";
      }
    };

    RegexTokenizer.prototype._start = function(stream, ch) {
      this.state = this._plain;
      if (ch === '/') {
        return "qualifier";
      } else {
        return this._plain(stream, ch);
      }
    };

    RegexTokenizer.prototype._characterClass = function(stream, ch) {
      var ent;
      ent = this.entering;
      this.entering = false;
      switch (ch) {
        case '[':
          this.ccDepth++;
          this.entering = true;
          return "meta";
        case ']':
          if (this.ccDepth-- === 0) {
            this.state = this._plain;
          }
          return "meta";
        case '-':
          return "qualifier";
        default:
          if (ent && ch === '^') {
            return "operator";
          } else {
            return "string";
          }
      }
    };

    RegexTokenizer.prototype._group = function(stream, ch) {
      var ent;
      ent = this.entering;
      this.entering = false;
      this.state = this._plain;
      if (ent && ch === '?') {
        this.state = this._name;
        return "tag";
      } else {
        return this._plain();
      }
    };

    RegexTokenizer.prototype._name = function(stream, ch) {
      this.state = this._group;
      if (ch === '<' || ch === '\'') {
        stream.skipTo(ch === '<' ? '>' : '\'');
        stream.next();
        return "tag";
      } else {
        return this._group(stream, ch);
      }
    };

    RegexTokenizer.prototype._options = function(stream, ch) {
      stream.skipToEnd();
      return "attribute";
    };

    return RegexTokenizer;

  })();

  CodeMirror.defineMode('regex', function() {
    return {
      startState: function() {
        return new RegexTokenizer;
      },
      token: function(stream, state) {
        return state.tokenize(stream);
      }
    };
  });

  RegexReplaceTokenizer = (function() {
    function RegexReplaceTokenizer() {}

    RegexReplaceTokenizer.prototype.tokenize = function(stream) {
      var ch;
      ch = stream.next();
      return null;
    };

    return RegexReplaceTokenizer;

  })();

  CodeMirror.defineMode('regex_replace', function() {
    return {
      startState: function() {
        return new RegexReplaceTokenizer;
      },
      token: function(stream, state) {
        return state.tokenize(stream);
      }
    };
  });

  window.Flavors || (window.Flavors = {});

  Flavors.JavaScript = (function() {
    function JavaScript() {}

    JavaScript.prototype.replace = function(pattern, corpus, replacement, callback) {
      var line, lines, mapped, regex;
      if (replacement === null || replace.length === 0) {
        return callback({
          replace: corpus
        });
      }
      if (regex = this.makeRegex(pattern)) {
        if (this.isCorpusTest(corpus)) {
          lines = corpus.split('\n');
          mapped = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = lines.length; _i < _len; _i++) {
              line = lines[_i];
              _results.push(line = line.replace(regex, replacement));
            }
            return _results;
          })();
          return callback({
            replace: mapped.join("\n")
          });
        } else {
          return callback({
            replace: corpus.replace(regex, replacement)
          });
        }
      }
    };

    JavaScript.prototype.match = function(pattern, corpus, callback) {
      var matches, regex;
      matches = {
        matchSummary: {
          failed: 0,
          passed: 0,
          total: 0,
          tests: this.isCorpusTest(corpus)
        }
      };
      if (!(regex = this.makeRegex(pattern))) {
        return matches;
      }
      if (matches.matchSummary.tests) {
        this.matchTests(regex, corpus, matches);
      } else {
        this.matchWholeCorpus(regex, corpus, matches);
      }
      return callback(matches);
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

    JavaScript.prototype.matchTests = function(regex, corpus, matches) {
      var line, lines, matcher, negativeMatcher, nonMatcher, offset, positiveMatcher, selectMatchType, _i, _len;
      nonMatcher = new Matcher(regex, matches);
      positiveMatcher = new PositiveMatcher(regex, matches);
      negativeMatcher = new NegativeMatcher(regex, matches);
      selectMatchType = function(line) {
        switch (line.charAt(1)) {
          case '+':
            return positiveMatcher;
          case '-':
            return negativeMatcher;
          default:
            return nonMatcher;
        }
      };
      lines = corpus.split("\n");
      matcher = nonMatcher;
      offset = 0;
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        regex.lastIndex = 0;
        if (line.charAt(0) === '#') {
          matcher = selectMatchType(line);
        } else {
          if (line.length) {
            matcher.match(line, offset);
          }
        }
        offset += line.length + 1;
      }
      return void 0;
    };

    JavaScript.prototype.isCorpusTest = function(corpus) {
      return /^#(\+|\-)/gm.test(corpus);
    };

    return JavaScript;

  })();

  Matcher = (function() {
    function Matcher(regex, matches) {
      this.regex = regex;
      this.matches = matches;
    }

    Matcher.prototype.match = function(line, offset) {};

    Matcher.prototype.pass = function(offset, line) {
      this.matches.matchSummary.passed++;
      this.matches.matchSummary.total++;
      return this.matches[offset.toString()] = [offset, line.length];
    };

    Matcher.prototype.fail = function(offset, line) {
      this.matches.matchSummary.failed++;
      this.matches.matchSummary.total++;
      return this.matches[offset.toString()] = [offset, line.length, 'match-fail'];
    };

    return Matcher;

  })();

  PositiveMatcher = (function(_super) {
    __extends(PositiveMatcher, _super);

    function PositiveMatcher() {
      _ref = PositiveMatcher.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    PositiveMatcher.prototype.match = function(line, offset) {
      var match;
      if (match = this.regex.exec(line)) {
        return this.pass(offset, line);
      } else {
        return this.fail(offset, line);
      }
    };

    return PositiveMatcher;

  })(Matcher);

  NegativeMatcher = (function(_super) {
    __extends(NegativeMatcher, _super);

    function NegativeMatcher() {
      _ref1 = NegativeMatcher.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    NegativeMatcher.prototype.match = function(line, offset) {
      var match;
      if (match = this.regex.exec(line)) {
        return this.fail(offset, line);
      } else {
        return this.pass(offset, line);
      }
    };

    return NegativeMatcher;

  })(Matcher);

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
      this.updateReplacement = __bind(this.updateReplacement, this);
      this.highlightMatches = __bind(this.highlightMatches, this);
      this.updateMatches = __bind(this.updateMatches, this);
      _ref2 = Refiddle.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Refiddle.prototype.literalRegex = /^\/[^\/]+\/\w*/m;

    Refiddle.prototype.events = {
      "click .save": function(e) {
        e.preventDefault();
        return this.form.submit();
      },
      "change .flavor-options [type=checkbox]": function(e) {
        var $t, option, pattern;
        pattern = this.getPattern();
        $t = $(e.currentTarget);
        option = $t.attr('name');
        if ($t.prop("checked")) {
          if (!(pattern.options.indexOf(option) >= 0)) {
            return this.regexEditor.setValue("/" + pattern.pattern + "/" + pattern.options + option);
          }
        } else {
          return this.regexEditor.setValue("/" + pattern.pattern + "/" + (pattern.options.replace(option, '')));
        }
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
      this.regexEditor = CodeMirror.fromTextArea(this.regexText[0], {
        mode: "regex"
      });
      this.regexEditor.on("viewportChange", this.resizeTextGroup);
      this.regexEditor.on("changes", this.updateMatches);
      this.regexEditor.on("changes", this.updateReplacement);
      this.corpusEditor = CodeMirror.fromTextArea(this.corpusText[0], {
        lineWrapping: true,
        lineNumbers: true,
        mode: "corpus"
      });
      this.corpusEditor.on("changes", this.updateMatches);
      this.replaceEditor = CodeMirror.fromTextArea(this.replaceText[0], {
        mode: "regex_replace"
      });
      this.replaceEditor.on("viewportChange", this.resizeTextGroup);
      this.replaceEditor.refresh();
      this.replaceEditor.on("changes", this.updateReplacement);
      this.resizeTextGroup();
      this.textGroup.find(".in").removeClass("in");
      this.textGroup.find(".panel-collapse:last").addClass("in");
      this.updateMatches();
      return this.updateReplacement();
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

    Refiddle.prototype.applyOptions = function(options) {
      var opt, _i, _len;
      $(".flavor-options [type=checkbox]").prop("checked", false);
      for (_i = 0, _len = options.length; _i < _len; _i++) {
        opt = options[_i];
        $(".flavor-options [name=" + opt + "]").prop("checked", true);
      }
      return void 0;
    };

    Refiddle.prototype.getCorpus = function() {
      return this.corpusEditor.getValue();
    };

    Refiddle.prototype.getReplacement = function() {
      return this.replaceEditor.getValue();
    };

    Refiddle.prototype.updateMatches = function() {
      var pattern,
        _this = this;
      pattern = this.getPattern();
      this.applyOptions(pattern.options);
      return this.flavor.match(pattern, this.getCorpus(), function(matches) {
        _this.matches = matches;
        return _this.highlightMatches(_this.matches);
      });
    };

    Refiddle.prototype.highlightMatches = function(matches) {
      var from, index, pair, to;
      this.updateMatchResults(matches);
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
          className: pair[2] || "match"
        });
      }
      return void 0;
    };

    Refiddle.prototype.updateMatchResults = function(matches) {
      var summary;
      summary = matches.matchSummary;
      $("html").toggleClass("with-tests", summary.tests);
      $("html").toggleClass("tests-passing", summary.failed === 0);
      $("html").toggleClass("tests-failing", summary.failed > 0);
      $(".match-results .total .count").text(summary.total);
      $(".match-results .pass .count").text(summary.passed);
      return $(".match-results .fail .count").text(summary.failed);
    };

    Refiddle.prototype.updateReplacement = function() {
      var _this = this;
      return this.flavor.replace(this.getPattern(), this.getCorpus(), this.getReplacement(), function(replacement) {
        return _this.replaceResults.text(replacement.replace);
      });
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
          height: availableHeight - $(this.replaceEditor.display.wrapper).outerHeight() - this.headerHeight * 2 - 5 - 5
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
