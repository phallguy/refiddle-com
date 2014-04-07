json.refiddle do
  json.url refiddle_url(@refiddle)
end
json.pagination json_paginate( @refiddle_patterns  )
json.collection @refiddle_patterns do |pattern|
  json.partial! pattern
end
