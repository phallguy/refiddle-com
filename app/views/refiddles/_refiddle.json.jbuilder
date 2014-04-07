json.id refiddle.id.to_s
json.url refiddle_url( refiddle )
json.partial! "timestamps", model: refiddle
json.(refiddle, :title, :description, :share, :locked, :short_code, :slug, :corpus_deliminator, :tags )
json.pattern do
  json.partial! refiddle.pattern
end

abbr ||= false
unless abbr
  json.revisions_count refiddle.revisions.count
  json.revisions_url refiddle_revisions_url(refiddle)
end