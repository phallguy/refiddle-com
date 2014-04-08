json.id refiddle.id.to_s
json.url refiddle_url( refiddle )
json.partial! "timestamps", model: refiddle
json.(refiddle, :title, :description, :share, :locked, :short_code, :slug, :corpus_deliminator, :tags )
json.pattern do
  json.partial! refiddle.pattern
end

abbr ||= false
unless abbr

  if refiddle.user
    json.user do
      json.partial! refiddle.user
    end
  end

  json.revisions_count refiddle.revisions.count
  json.revisions_url refiddle_revisions_url(refiddle)

  json.forks_count refiddle.forks.count
  json.forks_url refiddle_forks_url(refiddle)

  if refiddle.forked_from
    json.forked_from do
      json.id refiddle.forked_from.id.to_s
      json.url refiddle_url( refiddle.forked_from )
    end
  end
end