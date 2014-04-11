class Flavors.Remote
  remote: true

  match: ( pattern, corpus, callback ) ->
    $.post @matchUri, {
        pattern: "/#{pattern.pattern}/#{pattern.options}"
        corpus_text: corpus
        }, callback, "json"

  replace: ( pattern, corpus, replacement, callback ) ->
    $.post @replaceUri, {
        pattern: "/#{pattern.pattern}/#{pattern.options}"
        corpus_text: corpus
        replace_text: replacement
        }, callback, "json"
