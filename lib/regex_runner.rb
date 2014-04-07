module RegexRunner
  autoload :Base, "regex_runner/base"
  autoload :Remote, "regex_runner/remote"
  autoload :DotNet, "regex_runner/dot_net"
  autoload :Ruby, "regex_runner/ruby"


  class << self
    # Creates a new instance of a runner given it's name.
    def find( name )
      case name
      when /ruby/, :ruby, :Ruby; Ruby.new
      when /(\.|dot)net/i, :dotnet, :'.NET'; DotNet.new
      end
    end
  end
end