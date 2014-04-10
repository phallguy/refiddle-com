window.Flavors ||= {
  getFlavor: (name) ->
    switch name
      when "ruby" then new Flavors.Ruby
      else new Flavors.JavaScript
}