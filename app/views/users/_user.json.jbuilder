json.id user.id.to_s
json.url user_url(user)
json.(user,:name)

abbr ||= false
unless abbr
end