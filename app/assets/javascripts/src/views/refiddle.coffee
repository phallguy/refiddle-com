class App.Views.Refiddle extends Backbone.View
  literalRegex: /^\/[^\/]+\/\w*/m

  events:
    "click .save" : (e) ->
      e.preventDefault()
      @form.submit()


  initialize: (options={}) ->
    super

    @flavor = new Flavors.JavaScript()

    @form             = $("#refiddle-form")
    @textGroup        = $("#text")
    @regexText        = $("#refiddle_regex")
    @corpusText       = $("#refiddle_corpus_text")
    @replaceText      = $("#refiddle_replace_text")
    @replaceResults   = $("#replace_results")
    @headerHeight     = @textGroup.find( ".panel-heading" ).outerHeight()

    $(window).on "resize", =>
      @resizeTextGroup()


    @regexEditor = CodeMirror.fromTextArea( @regexText[0] )
    @regexEditor.on "viewportChange", @resizeTextGroup
    @regexEditor.on "changes", @updateMatches

    @corpusEditor = CodeMirror.fromTextArea @corpusText[0],
      lineWrapping: true
      lineNumbers: true
    @corpusEditor.on "changes", @updateMatches



    @replaceEditor = CodeMirror.fromTextArea( @replaceText[0] )
    @replaceEditor.on "viewportChange", @resizeTextGroup
    @replaceEditor.refresh()


    @resizeTextGroup()

    # Need to do this so CodeMirror can initialize on the replace text box.
    @textGroup.find(".in").removeClass("in")
    @textGroup.find(".panel-collapse:first").addClass("in")

    @updateMatches()


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

  getCorpus: ->
    @corpusEditor.getValue()

  updateMatches: =>
    @matches = @flavor.match( @getPattern(), @getCorpus() )
    @highlightMatches( @matches )

  highlightMatches: (matches) =>
    _.each @corpusEditor.getAllMarks(), (m) ->
      m.clear()

    for index, pair of matches
      continue if index == "matchSummary"
      from  = @corpusEditor.doc.posFromIndex( pair[0] )
      to    = @corpusEditor.doc.posFromIndex( pair[0] + pair[1] )

      @corpusEditor.markText( from, to, className: "match" )
    undefined


  resizeTextGroup: =>
    @resizeTextGroupDebounced ||= _.debounce @_resizeTextGroup, 50, true
    @resizeTextGroupDebounced()

  _resizeTextGroup: ->
    if $(window).width() >= 768
      availableHeight = $(window).height() - @textGroup.offset().top - 15 # grid gutter

      @corpusEditor.setSize( null, availableHeight - @headerHeight * 2 - 5 - 5 )
      @replaceResults.css( height: availableHeight - @replaceText.outerHeight() - @headerHeight * 2 - 5 - 5 ) # ( panel margin ) ( border width * 5 borders )
    else
      @corpusEditor.setSize( null, "" )
      @replaceResults.css( height: "" )