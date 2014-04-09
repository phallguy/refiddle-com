class App.Views.Refiddle extends Backbone.View
  events:
    "click .save" : (e) ->
      e.preventDefault()
      @form.submit()


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


    @regexEditor = CodeMirror.fromTextArea( @regexText[0] )
    @regexEditor.on "viewportChange", @resizeTextGroup

    @corpusEditor = CodeMirror.fromTextArea @corpusText[0],
      lineWrapping: true
      lineNumbers: true

    @replaceEditor = CodeMirror.fromTextArea( @replaceText[0] )
    @replaceEditor.on "viewportChange", @resizeTextGroup
    @replaceEditor.refresh()


    @resizeTextGroup()

    # Need to do this so CodeMirror can initialize on the replace text box.
    @textGroup.find(".in").removeClass("in")
    @textGroup.find(".panel-collapse:first").addClass("in")



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