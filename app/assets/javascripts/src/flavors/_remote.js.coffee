class Flavors.Remote
  remote: true

  match: ( pattern, corpus, callback ) ->
    if @matching
      @nextMatch = arguments
    else
      @matching = true
      @_match.apply this, arguments
  
  _match: ( pattern, corpus, callback ) ->
    $.ajax
        url: @matchUri
        method: "POST"
        complete: =>
          if @nextMatch
            args = @nextMatch
            @nextMatch = null
            @_match.apply this, args
          else
            @matching = false
        success: callback
        error: ( xhr, status, error ) ->
          callback xhr.responseJSON
        dataType: "json"
        data:
          pattern: "/#{pattern.pattern}/#{pattern.options}"
          corpus_text: corpus
        

  replace: ( pattern, corpus, replacement, callback ) ->
    if @replacing
      @nextReplace = arguments
    else
      @replacing = true
      @_replace.apply this, arguments

  _replace: ( pattern, corpus, replacement, callback ) ->
    $.ajax 
        url: @replaceUri
        method: "POST"
        complete: =>
          if @nextReplace
            args = @nextReplace
            @nextReplace = null
            @_replace.apply this, args
          else
            @replacing = false
        success: callback
        error: ( xhr, status, error ) ->
          callback xhr.responseJSON
        dataType: "json"
        data:
          pattern: "/#{pattern.pattern}/#{pattern.options}"
          corpus_text: corpus
          replace_text: replacement
