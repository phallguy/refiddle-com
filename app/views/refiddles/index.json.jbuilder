json.pagination json_paginate(@refiddles)
json.collection @refiddles do |refiddle|
  json.partial! refiddle
end