class Flavors.JavaScript



  match: ( pattern, corpus ) ->
    matches =
      matchSummary:
        failed: 0
        passed: 0
        total: 0
        tests: false

    unless regex = @makeRegex( pattern )
      return matches

    unless matches.matchSummary.tests
      @matchWholeCorpus( regex, corpus, matches )

    matches


  makeRegex: (pattern) ->
    try
      new RegExp( pattern.pattern, pattern.options )
    catch e
      console.log "Oops, invalid regex #{e}"
      null


  matchWholeCorpus: (regex,corpus,matches) ->
    mx = 0
    while match = regex.exec(corpus)

      pair = [ match.index, match[0].length ]
      matches[mx.toString()] = pair
      matches.matchSummary.total++

      return unless regex.global
      mx++

      if mx > corpus.length * 2
        # Just in case the regex runs wild, short-circuit here
        break

      break if regex.lastIndex >= corpus.length




    