json.id user.id.to_s
json.url user_url(user.id)
json.profile_url profile_url(user.slug||user.id)
json.(user,:name,:slug)

abbr ||= false
unless abbr
end