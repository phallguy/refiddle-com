class RegexTokenizer

  tokenize: ( stream ) ->
    @state ||= @_start
    ch = stream.next()
    if ch == '\\'
      stream.next()
      "quote"
    else
      @state( stream, ch )

  _comment: (stream) ->
    "comment"

  _plain: (stream, ch)->
    switch ch
      when '/'
        @state = @_options
        "qualifier"
      when "["
        @entering = true
        @ccDepth = 0
        @state = @_characterClass
        "meta"
      when "("
        @entering = true        
        @state = @_group
        "bracket"
      when ")"
        "bracket"
      when "{"
        stream.next() if stream.skipTo '}'
        "tag"
      when ".", "*", "?", '|'
        "operator"
      when "^", "$"
        "atom"

  _start: (stream, ch) ->
    @state = @_plain    
    if ch == '/'
      "qualifier"
    else
      @_plain( stream, ch )

  _characterClass: ( stream, ch ) ->
    ent = @entering
    @entering = false
    switch ch
      when '['
        @ccDepth++
        @entering = true
        "meta"
      when ']'
        if @ccDepth-- == 0
          @state = @_plain
        "meta"
      when '-'
        "qualifier"
      else
        if ent && ch == '^'
          "operator"
        else
          "string"

  _group: (stream, ch ) ->
    ent = @entering
    @entering = false
    @state = @_plain
    if ent && ch == '?'
      @state = @_name
      "tag"    
    else
      @_plain()

  _name: ( stream, ch ) ->
    @state = @_group
    if ch == '<' || ch == '\''
      stream.skipTo if ch == '<' then '>' else '\''
      stream.next()
      "tag"
    else
      @_group stream, ch

  _options: ( stream, ch ) ->
    stream.skipToEnd()
    "attribute"


CodeMirror.defineMode 'regex', ->
  {  
    startState: -> new RegexTokenizer
    token: ( stream, state ) ->
      state.tokenize( stream )
  }

