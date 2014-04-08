json.user do
  json.partial! @user
end
json.public_refiddles do 
  json.partial! "shared/paged_collection", collection: @refiddles
end