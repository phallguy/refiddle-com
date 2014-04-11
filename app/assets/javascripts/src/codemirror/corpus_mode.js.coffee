class CorpusTokenizer

  tokenize: ( stream ) ->
    @state ||= @_plain
    sol = stream.sol()
    ch = stream.next()
    if sol && ch == '#'
      @changeState( stream )
    else
      @state( stream, ch )

  changeState: ( stream ) ->
    @state = switch stream.peek()
      when "+" then @_operator
      when "-" then @_operator
      when "#" then @_comment
    "bracket"

  _operator: (stream, ch) ->
    switch ch
      when "+", "-"
        "operator"
      when '#'
        @state = @_comment
        stream.skipToEnd()
        "comment"
      else
        stream.skipToEnd()
        @state = @_plain
        "header"

  _comment: (stream) ->
    stream.skipToEnd()
    "comment"

  _plain: (stream)->
    stream.skipToEnd()
    null



CodeMirror.defineMode 'corpus', ->
  {  
    startState: -> new CorpusTokenizer
    token: ( stream, state ) ->
      state.tokenize( stream )
  }

