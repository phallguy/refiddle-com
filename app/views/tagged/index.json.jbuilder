json.tags @tags do |tag|
  json.name tag
  json.url tagged_url( tag )
end

json.partial! "shared/paged_collection", collection: @refiddles
