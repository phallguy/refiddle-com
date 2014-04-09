class App.Views.Refiddle extends Backbone.View
  events:
    "click .save" : (e) ->
      e.preventDefault()
      @form.submit()


  initialize: (options={}) ->
    super
    @form             = $("#refiddle-form")
    @textGroup        = $("#text")
    @corpusText       = $("#refiddle_corpus_text")
    @replaceText      = $("#refiddle_replace_text")
    @replaceResults   = $("#replace_results")
    @headerHeight     = @textGroup.find( ".panel-heading" ).outerHeight()
    @resizeTextGroup()

    $(window).on "resize", =>
      @resizeTextGroup()


  resizeTextGroup: ->
    if $(window).width() >= 768
      availableHeight = $(window).height() - @textGroup.offset().top - 15 # grid gutter

      @corpusText.css( height: availableHeight - @headerHeight * 2 - 5 - 5 ) # ( panel margin ) ( border width * 5 borders )
      @replaceResults.css( height: availableHeight - @replaceText.outerHeight() - @headerHeight * 2 - 5 - 5 ) # ( panel margin ) ( border width * 5 borders )
    else
      @corpusText.css( height: "" )
      @replaceResults.css( height: "" )