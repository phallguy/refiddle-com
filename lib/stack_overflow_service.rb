class StackOverflowService


  def fetch_questions(tagged,limit=100)
    http = Net::HTTP.start( "api.stackoverflow.com" )
    res = http.get( "/1.1/search?tagged=#{URI.escape(tagged)}&pagesize=#{limit}" )
    MultiJson.load( res.body, symbolize_keys: true )
  end

  def fetch_question(id)
    http = Net::HTTP.start( "api.stackoverflow.com" )
    res = http.get( "/1.1/questions/#{id}?answers=true&body=true" )

    question = MultiJson.load( res.body, symbolize_keys: true )[:questions].first

    related_fiddles = find_related_fiddles( question[:body] ) || []

    question[:answers].each do |a|
      related_fiddles += find_related_fiddles( a[:body] ) || []
    end
    
    related_fiddles.uniq!
    
    question[:related_fiddles] = related_fiddles

    question
  end

  private 

    def find_related_fiddles( text )
      text.scan( /https?:\/\/refiddle\.com\/(\w+)/ )
    end

end