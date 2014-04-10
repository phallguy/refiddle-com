class RegexReplaceTokenizer

  tokenize: ( stream ) ->
    ch = stream.next()
    null

CodeMirror.defineMode 'regex_replace', ->
  {  
    startState: -> new RegexReplaceTokenizer
    token: ( stream, state ) ->
      state.tokenize( stream )
  }

