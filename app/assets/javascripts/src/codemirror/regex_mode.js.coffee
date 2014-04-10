class RegexTokenizer

  tokenize: ( stream ) ->
    ch = stream.next()
    null

CodeMirror.defineMode 'regex', ->
  {  
    startState: -> new RegexTokenizer
    token: ( stream, state ) ->
      state.tokenize( stream )
  }

