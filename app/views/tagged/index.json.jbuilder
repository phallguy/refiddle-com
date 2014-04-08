json.tags @tags do |tag|
  json.name tag
  json.url tagged_url( tag )
end
json.pagination json_paginate( @refiddles )
json.collection @refiddles do |refiddle|
  json.partial! refiddle
end