window.Flavors ||= {
  getFlavor: (name) ->
    switch name
      when "ruby" then new Flavors.Ruby
      when "net" then new Flavors.Net
      else new Flavors.JavaScript
}