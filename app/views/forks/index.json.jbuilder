json.pagination json_paginate(@forks)
json.collection @forks do |fork|
  json.partial! fork
end