  json.id question[:question_id]
  json.url show_stackoverflow_url( question[:question_id], title: question[:title].parameterize )
  json.title question[:title]
  json.tags question[:tags]
  json.body question[:body]
  json.score question[:score]
  json.answer_count question[:answer_count]
  json.link_url "http://stackoverflow.com/questions/#{question[:question_id]}/#{question[:title].parameterize}"
  if question[:error]
    json.error do
      json.message question[:error].try(:message)
      json.backtrace question[:error].try(:backtrace)
    end
  end