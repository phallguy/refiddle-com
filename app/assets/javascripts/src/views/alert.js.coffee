class App.Views.Alert extends Backbone.View

  events: 
    "click" : ->
      @hide()

  className: ->
    "alert alert-#{@kind}"

  initialize: (options={}) ->
    @errors = options.errors
    @message = options.message || @createErrorMessage()
    @kind = options.kind || ( if @errors then "danger" else "info" )

  show: ->
    alerts = $('.page-alerts')
    alerts.find(".alert").remove()    
    @render()

    @$el.addClass("slide up")
    alerts.append( @$el )

    _.defer =>
      @$el.addClass("in")

      _.delay @hide, 7000

    @

  render: ->
    @$el.attr("class", @className())
    @$el.html(@message)
    @

  createErrorMessage: ->
    if @errors
      result = for err in @errors
        "<p>#{err.message || err}</p>"
    else
      "There was an error."

  hide: =>
    @$el.removeClass("in")
    _.delay ( => @$el.remove() ), 3000