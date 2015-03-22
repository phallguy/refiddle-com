class RegexRunner::DotNet < RegexRunner::Remote
  def server
    ENV['DOT_NET_RUNNER'] || "http://dotnet.refiddle.com/regex/"
  end  
end