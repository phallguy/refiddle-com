class Flavors.JavaScript

  replace: ( pattern, corpus, replacement, callback ) ->
    if replacement == null || replace.length == 0
      return callback( replace: corpus )

    if regex = @makeRegex( pattern )
      if @isCorpusTest( corpus )
        lines = corpus.split('\n')
        mapped = for line in lines
          line = line.replace( regex, replacement )
        callback( replace: mapped.join("\n") )
      else
        callback( replace: corpus.replace( regex, replacement ) )


  match: ( pattern, corpus, callback ) ->
    matches =
      matchSummary:
        failed: 0
        passed: 0
        total: 0
        tests: @isCorpusTest( corpus )

    unless regex = @makeRegex( pattern )
      return matches

    if matches.matchSummary.tests
      @matchTests( regex, corpus, matches )
    else
      @matchWholeCorpus( regex, corpus, matches )

    callback( matches )


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

  matchTests: (regex,corpus,matches) ->
    nonMatcher        = new Matcher( regex, matches )
    positiveMatcher   = new PositiveMatcher( regex, matches )
    negativeMatcher   = new NegativeMatcher( regex, matches )

    selectMatchType = (line ) ->
      switch line.charAt(1)
        when '+' then positiveMatcher
        when '-' then negativeMatcher
        else nonMatcher

    lines   = corpus.split "\n"
    matcher = nonMatcher
    offset  = 0

    for line in lines
      regex.lastIndex = 0

      if line.charAt(0) == '#'
        matcher = selectMatchType(line)
      else
        matcher.match( line, offset ) if line.length

      offset += line.length + 1

    undefined

  isCorpusTest: (corpus) ->
    /^#(\+|\-)/gm.test( corpus )

class Matcher
  constructor: (regex, matches ) ->
    @regex = regex
    @matches = matches

  match: (line,offset) ->

  pass: ( offset, line ) ->
    @matches.matchSummary.passed++
    @matches.matchSummary.total++
    @matches[offset.toString()] = [ offset, line.length ]

  fail: ( offset, line ) ->
    @matches.matchSummary.failed++
    @matches.matchSummary.total++
    @matches[offset.toString()] = [ offset, line.length, 'nomatch' ]


class PositiveMatcher extends Matcher
  match: (line,offset) ->
    if match = @regex.exec( line )
      @pass( offset, line )
    else
      @fail( offset, line )

class NegativeMatcher extends Matcher
  match: (line,offset) ->
    if match = @regex.exec( line )
      @fail( offset, line )
    else
      @pass( offset, line )

