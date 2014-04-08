json.refiddle do
  json.url refiddle_url(@refiddle)
end
json.pagination json_paginate( @refiddle_patterns  )


json.collection do
    @refiddle_patterns.each_with_index do |pattern,index|
      json.child! do
        json.partial! pattern
        if previous = @refiddle_patterns[index-1]
          json.diff previous.diff( pattern ).slice(:regex_ex, :corpus_text_ex, :replace_text_ex )
        end
      end
    end
end
