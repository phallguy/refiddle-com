json.pagination json_paginate( @questions )
json.downloading @recent[:downloading]
json.collection @questions do |question|
  json.partial! "stackoverflow/question", question: question

  # json.raw question
end
if @recent[:error]
  json.error do
    json.message @recent[:error].try(:message)
    json.backtrace @recent[:error].try(:backtrace)
  end
end