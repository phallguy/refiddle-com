class App.Views.Refiddle extends Backbone.View
  literalRegex: /^\/[^\/]+\/\w*/m
  debounceRate: 250

  events:
    "click .save" : (e) ->
      e.preventDefault()
      @form.submit()

    "change .flavor-options [type=checkbox]" : (e) ->
      pattern = @getPattern()
      $t = $(e.currentTarget)
      option = $t.attr('name')

      if $t.prop("checked")
        unless pattern.options.indexOf(option) >= 0
          @regexEditor.setValue( "/#{pattern.pattern}/#{pattern.options}#{option}" )
      else
        @regexEditor.setValue( "/#{pattern.pattern}/#{pattern.options.replace( option, '' )}" )

    "change #refiddle_flavor" : ->
      @chooseFlavor()
      @updateMatches()
      @updateReplacement()


  initialize: (options={}) ->
    super

    @form             = $("#refiddle-form")
    @textGroup        = $("#text")
    @regexText        = $("#refiddle_regex")
    @corpusText       = $("#refiddle_corpus_text")
    @replaceText      = $("#refiddle_replace_text")
    @replaceResults   = $("#replace_results")
    @headerHeight     = @textGroup.find( ".panel-heading" ).outerHeight()

    $(window).on "resize", =>
      @resizeTextGroup()

    @chooseFlavor()


    @regexEditor = CodeMirror.fromTextArea @regexText[0],
      mode: "regex"      
    @regexEditor.on "viewportChange", @resizeTextGroup
    @regexEditor.on "changes", @updateMatches
    @regexEditor.on "changes", @updateReplacement

    @corpusEditor = CodeMirror.fromTextArea @corpusText[0],
      lineWrapping: true
      lineNumbers: true
      mode: "corpus"
    @corpusEditor.on "changes", @updateMatches

    @replaceEditor = CodeMirror.fromTextArea @replaceText[0],
      mode: "regex_replace"
    @replaceEditor.on "viewportChange", @resizeTextGroup
    @replaceEditor.refresh()
    @replaceEditor.on "changes", @updateReplacement


    @resizeTextGroup()

    # Need to do this so CodeMirror can initialize on the replace text box.
    @textGroup.find(".in").removeClass("in")
    @textGroup.find(".panel-collapse:first").addClass("in")

    @updateMatches()
    @updateReplacement()


  getPattern: ->
    @parsePattern @regexEditor.getValue()

  parsePattern: (pattern,options) ->
    parsed = 
      pattern: pattern
      options: options || ""
      lteral: false

    if @literalRegex.test( pattern )
      ix = pattern.lastIndexOf '/'
      ops = pattern.substring( ix + 1 )

      parsed.pattern = pattern.substring( 1, ix ).replace('\\/','/')
      parsed.options = ops
      parsed.literal = true

    parsed.global = parsed.options.indexOf('g') > -1

    parsed

  applyOptions: (options) ->
    $(".flavor-options [type=checkbox]").prop("checked", false)
    for opt in options
      $(".flavor-options [name=#{opt}]").prop("checked", true)
    undefined

  chooseFlavor: ->
    @form.removeClass (index,css) ->
      ( css.match(/flavor-.*/i) || [] ).join(" ")

    opt = $( "#refiddle_flavor option:selected" )
    flavor = opt.data('flavor')
    @form.addClass( "flavor-#{opt.data('flavor')}" )
    @flavor = Flavors.getFlavor( flavor )    

  getCorpus: ->
    @corpusEditor.getValue()

  getReplacement: ->
    @replaceEditor.getValue()

  showErrors: (response) ->
    @alert = new App.Views.Alert( response ).show()

  hideErrors: ->
    @alert && @alert.hide()


  updateMatches: =>
    @updateMatchesDebounced ||= _.throttle @_updateMatches, @debounceRate, true
    @updateMatchesDebounced()

  _updateMatches: ->
    pattern = @getPattern()
    @applyOptions( pattern.options )

    $("#corpus").addClass( "refreshing" )
    @flavor.match pattern, @getCorpus(), (matches) =>
      $("#corpus").removeClass( "refreshing" )
      @matches = matches
      if matches.errors
        @showErrors(matches)
      else
        @hideErrors()
        @highlightMatches( @matches )


  highlightMatches: (matches) =>
    @updateMatchResults( matches )

    _.each @corpusEditor.getAllMarks(), (m) ->
      m.clear()

    for index, pair of matches
      continue if index == "matchSummary"
      from  = @corpusEditor.doc.posFromIndex( pair[0] )
      to    = @corpusEditor.doc.posFromIndex( pair[0] + pair[1] )

      @corpusEditor.markText( from, to, className: pair[2] || "match" )
    undefined

  updateMatchResults: (matches) ->
    if matches.error

    else
      summary = matches.matchSummary

      $("html").toggleClass( "with-tests", !!summary.tests )
      $("html").toggleClass( "tests-passing", summary.failed == 0 )
      $("html").toggleClass( "tests-failing", summary.failed > 0 )

      $(".match-results .total .count").text( summary.total )
      $(".match-results .pass .count").text( summary.passed )
      $(".match-results .fail .count").text( summary.failed )


  updateReplacement: =>
    @updateReplacementDebounced ||= _.debounce @_updateReplacement, @debounceRate, true
    @updateReplacementDebounced()

  _updateReplacement: ->
    $("#replace").addClass("refreshing")
    @flavor.replace @getPattern(), @getCorpus(), @getReplacement(), (replacement) =>
      $("#replace").removeClass("refreshing")
      if replacement.errors
        @showErrors(replacement)
      else
        @replaceResults.text( replacement.replace )

  resizeTextGroup: =>
    @resizeTextGroupDebounced ||= _.throttle @_resizeTextGroup, @debounceRate, true
    @resizeTextGroupDebounced()

  _resizeTextGroup: ->

    if $(window).width() >= 768
      availableHeight = $(window).height() - @textGroup.offset().top - 15 # grid gutter

      @corpusEditor.setSize( null, availableHeight - @headerHeight * 2 - 5 - 5 )
      @replaceResults.css( height: availableHeight - $( @replaceEditor.display.wrapper ).outerHeight() - @headerHeight * 2 - 5 - 5 ) # ( panel margin ) ( border width * 5 borders )
    else
      @corpusEditor.setSize( null, "" )
      @replaceResults.css( height: "" )